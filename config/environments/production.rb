TrustyCms::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Use a different logger for distributed setups
  # config.logger        = SyslogLogger.new

  # Full error reports are disabled and caching is on
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host                  = "http://assets.example.com"

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Disable delivery errors if you bad email addresses should just be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Cache your content for a longer time, the default is 5.minutes
  # config.after_initialize do
  #   SiteController.cache_timeout = 12.hours
  # end

end
