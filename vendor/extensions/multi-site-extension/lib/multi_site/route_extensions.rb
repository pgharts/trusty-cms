module MultiSite
  module RouteExtensions

    def self.included(base)
      base.alias_method :recognition_conditions_without_site, :recognition_conditions
      base.alias_method :recognition_conditions, :recognition_conditions_with_site
    end

    def recognition_conditions_with_site
      result = recognition_conditions_without_site
      if site_names = conditions.delete(:site)
        domains = [*site_names].map{ |site| Regexp.compile(::Site.find_by_name(site).domain) }
        conditions[:site] = Regexp.union(*domains)
        result << "conditions[:site] === env[:site]"
      end
      result
    end

  end
end

ActionController::Routing::Route.send :include, MultiSite::RouteExtensions
