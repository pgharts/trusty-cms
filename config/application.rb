require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'acts_as_tree'
require 'configuration_extensions/configuration_extensions'
require 'radius'
require 'trusty_cms/extension_loader'
require 'trusty_cms/initializer'
require 'compass'
require 'rack/cache'
require 'trustygems'


if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module TrustyCms
  class Application < Rails::Application
    include TrustyCms::Initializer
    config.active_record.whitelist_attributes = true
    config.autoload_paths += %W(#{config.root}/lib)
    config.eager_load_paths << Rails.root.join('lib')
    Sass.load_paths << Compass::Frameworks['compass'].stylesheets_directory

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # Initialize extension paths
    config.initialize_extension_paths
    extension_loader = ExtensionLoader.instance {|l| l.initializer = self }
    extension_loader.paths(:load).reverse_each do |path|
      config.autoload_paths.unshift path
      $LOAD_PATH.unshift path
    end
    paths["app/helpers"] = []
    # config.add_plugin_paths(extension_loader.paths(:plugin))
    radiant_locale_paths = Dir[File.join(TRUSTY_CMS_ROOT, 'config', 'locales', '*.{rb,yml}')]
    config.i18n.load_path = radiant_locale_paths + extension_loader.paths(:locale)
    I18n.enforce_available_locales = true

    config.encoding = 'utf-8'

    # Skip frameworks you're not going to use (only works if using vendor/rails).
    # To use Rails without a database, you must remove the Active Record framework
    # config.frameworks -= [ :action_mailer ]

    # Only load the extensions named here, in the order given. By default all
    # extensions in vendor/extensions are loaded, in alphabetical order. :all
    # can be used as a placeholder for all extensions not explicitly named.
    # config.extensions = [ :all ]

    # By default, only English translations are loaded. Remove any of these from
    # the list below if you'd like to provide any of the additional options
    # config.ignore_extensions []

    # Comment out this line if you want to turn off all caching, or
    # add options to modify the behavior. In the majority of deployment
    # scenarios it is desirable to leave TrustyCms's cache enabled and in
    # the default configuration.
    #
    # Additional options:
    #  :use_x_sendfile => true
    #    Turns on X-Sendfile support for Apache with mod_xsendfile or lighttpd.
    #  :use_x_accel_redirect => '/some/virtual/path'
    #    Turns on X-Accel-Redirect support for nginx. You have to provide
    #    a path that corresponds to a virtual location in your webserver
    #    configuration.
    #  :entitystore => "radiant:tmp/cache/entity"
    #    Sets the entity store type (preceding the colon) and storage
    #   location (following the colon, relative to Rails.root).
    #    We recommend you use radiant: since this will enable manual expiration.
    #  :metastore => "radiant:tmp/cache/meta"
    #    Sets the meta store type and storage location.  We recommend you use
    #    radiant: since this will enable manual expiration and acceleration headers.


    config.middleware.use Rack::Cache,
                          :private_headers => ['Authorization'],
                          :entitystore => "radiant:tmp/cache/entity",
                          :metastore => "radiant:tmp/cache/meta",
                          :verbose => false,
                          :allow_reload => false,
                          :allow_revalidate => false
    # TODO: There's got to be a better place for this, but in order for assets to work fornow, we need ConditionalGet
    # TODO: Workaround from: https://github.com/rtomayko/rack-cache/issues/80
    config.middleware.insert_before(Rack::ConditionalGet, Rack::Cache)
    config.assets.enabled = true
    config.assets.paths << Rails.root.join('vendor', 'assets', 'bower_components')


    config.filter_parameters += [:password, :password_confirmation]

    # Use the database for sessions instead of the cookie-based default,
    # which shouldn't be used to store highly confidential information
    # (create the session table with 'rake db:sessions:create')
    # config.action_controller.session_store = :cookie_store DEPRECATED

    # Activate observers that should always be running
    config.active_record.observers = :user_action_observer

    # The internationalization framework can be changed to have another default locale (standard is :en) or more load paths.
    # All files from config/locales/*.rb,yml are added automatically.
    # config.i18n.load_path << Dir[File.join(Rails.root, 'my', 'locales', '*.{rb,yml}')]
    # config.i18n.default_locale = :'en'

    # Make Active Record use UTC-base instead of local time
    config.time_zone = 'UTC'

    # Set the default field error proc
    config.action_view.field_error_proc = Proc.new do |html, instance|
      if html !~ /label/
        %{<span class="error-with-field">#{html} <span class="error">#{[instance.error_message].flatten.first}</span></span>}
      else
        html
      end
    end
    config.after_initialize do
      extension_loader.load_extensions
      extension_loader.load_extension_initalizers

      extension_loader.activate_extensions  # also calls initialize_views
      #config.add_controller_paths(extension_loader.paths(:controller))
      #config.add_eager_load_paths(extension_loader.paths(:eager_load))

      # Add new inflection rules using the following format:
      ActiveSupport::Inflector.inflections do |inflect|
        inflect.uncountable 'config'
      end
    end
  end
end
