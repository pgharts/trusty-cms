TrustyCms::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false
  config.eager_load = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and caching is turned off
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false

  # Raise an ActiveModel::MassAssignmentSecurity::Error any time
  # something is mass-assigned that shouldn't be for ease in debugging.
  # config.active_record.mass_assignment_sanitizer = :strict

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true
end
