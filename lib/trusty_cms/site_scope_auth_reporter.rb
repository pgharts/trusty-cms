module TrustyCms
  # Observe-only telemetry for the intermittent CMS logout bug (diagnostic for
  # issue #1040). It changes NO behavior.
  #
  # When the multi_site extension is active, `User` carries a site-scoped
  # default_scope (an INNER JOIN on admins_sites for `Page.current_site`).
  # Devise deserializes the session user every request through that scope, so if
  # `current_site` points at a site the user is not assigned to, the lookup
  # returns nil and the user is logged out. Because `current_site` is
  # process-global mutable state shared across Puma threads, we suspect this is
  # usually a race (the user IS on a site they belong to, but the global was
  # clobbered by a concurrent request for another host).
  #
  # This reporter fires only when a session lookup misses BUT the user actually
  # exists (unscoped) — i.e. a valid user was excluded by the site scope — and
  # records enough context to tell a race from a genuine cross-site access or an
  # unmatched-host fallback. It never raises into the auth path.
  module SiteScopeAuthReporter
    MESSAGE = 'CMS site-scope logout (possible current_site race)'.freeze

    module_function

    def report_miss(key)
      return unless multi_site_scoped?

      excluded = User.unscoped { User.to_adapter.get(key) }
      return if excluded.nil? # ordinary unknown/expired session — not our bug

      context = build_context(excluded)
      Rails.logger.warn("[multi_site] #{MESSAGE} #{context.to_json}")
      Honeybadger.notify(MESSAGE, context: context) if defined?(Honeybadger)
      nil
    rescue StandardError => e
      # Telemetry must never break authentication.
      Rails.logger.error("[multi_site] SiteScopeAuthReporter error: #{e.class}: #{e.message}")
      nil
    end

    # Only meaningful when User is actually site-scoped by the multi_site
    # extension; otherwise the scoped and unscoped lookups are identical.
    def multi_site_scoped?
      User.respond_to?(:is_site_scoped?) && User.is_site_scoped?
    end

    def build_context(user)
      current = current_site
      host = Thread.current[:trusty_request_host]
      expected = expected_site_for(host)
      site_ids = user.site_ids

      {
        user_id: user.id,
        user_admin: user.admin?,
        user_site_ids: site_ids,
        current_site_id: current&.id,
        current_site_name: current&.name,
        current_site_domain_blank: current.present? && current.domain.blank?,
        request_host: host,
        expected_site_id: expected&.id,
        expected_site_name: expected&.name,
        classification: classify(site_ids, current, expected, host),
        thread: Thread.current.object_id,
        at: Time.now.utc.iso8601,
      }
    end

    # race               -> user belongs to the host's site, but current_site is
    #                       something else (the global was clobbered)
    # genuine_cross_site -> user hit a host whose site they are not assigned to
    # host_unmatched     -> request host matched no site (asset/unknown host);
    #                       current_site falls back to the default site
    # no_host_captured   -> ran outside a captured request (e.g. rake/console)
    def classify(site_ids, current, expected, host)
      return 'no_host_captured' if host.blank?
      return 'host_unmatched' if expected.nil?
      return 'race' if site_ids.include?(expected.id) && (current.nil? || site_ids.exclude?(current.id))
      return 'genuine_cross_site' if site_ids.exclude?(expected.id)

      'unknown'
    end

    def current_site
      Page.current_site if Page.respond_to?(:current_site)
    end

    # Mirrors Site.find_for_host's matching but WITHOUT the Site.default /
    # catchall fallback, so telemetry never creates a record and returns nil when
    # the host matches no site.
    def expected_site_for(host)
      return nil if host.blank?

      Site.where.not(domain: nil).detect do |site|
        host == site.base_domain || host =~ Regexp.compile(site.domain.to_s)
      end
    rescue RegexpError
      nil
    end
  end
end
