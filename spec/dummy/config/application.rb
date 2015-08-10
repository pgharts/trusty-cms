require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'acts_as_tree'
require 'ckeditor'
require 'radius'
require 'trusty_cms/extension_loader'
require 'trusty_cms/initializer'
require 'string_extensions/string_extensions'
require 'active_record_extensions/active_record_extensions'
require 'configuration_extensions/configuration_extensions'
require 'compass'
require 'rack/cache'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module TrustyCms
  class Application < Rails::Application

    attr_accessor :captcha_public_key, :captcha_private_key
    attr_accessor :extensions_migration_order
    attr_accessor :tessitura_service_url
    attr_accessor :assets_copy_cap_stage
    attr_accessor :mock_server
    attr_accessor :parking_season_type_ids
    attr_accessor :server_ip_address
    attr_accessor :facility_root
    attr_accessor :contact_us_root
    attr_accessor :custom_form_root
    attr_accessor :guest_user
    attr_accessor :javascript_include_base_path
    attr_accessor :production_sync_interval, :package_sync_interval, :google_map_key
    attr_accessor :order_expiration_time
    attr_accessor :skip_captcha_environments
    attr_accessor :domain
    attr_accessor :test_email_recipients

    include TrustyCms::Initializer

    config.autoload_paths += %W(#{TRUSTY_CMS_ROOT}/lib)
    config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths += %W(#{config.root}/app/helpers)

    Sass.load_paths << Compass::Frameworks['compass'].stylesheets_directory

    # Initialize extension paths
    config.initialize_extension_paths
    extension_loader = ExtensionLoader.instance {|l| l.initializer = self }
    extension_loader.paths(:load).reverse_each do |path, value|
      config.autoload_paths.unshift path
      $LOAD_PATH.unshift path
    end
    # config.add_plugin_paths(extension_loader.paths(:plugin))
    radiant_locale_paths = Dir[File.join(TRUSTY_CMS_ROOT, 'config', 'locales', '*.{rb,yml}')]
    config.i18n.load_path = radiant_locale_paths + extension_loader.paths(:locale)

    config.encoding = 'utf-8'
    # Skip frameworks you're not going to use (only works if using vendor/rails).
    # To use Rails without a database, you must remove the Active Record framework
    # config.frameworks -= [ :action_mailer ]

    # Only load the extensions named here, in the order given. By default all
    # extensions in vendor/extensions are loaded, in alphabetical order. :all
    # can be used as a placeholder for all extensions not explicitly named.

    # An example of how to add extensions:
    # config.extensions = [ :snippets, :clipped, :layouts, :reorder, :multi_site, :rad_social]

    config.extensions = []
    config.extensions_migration_order = []

    # By default, only English translations are loaded. Remove any of these from
    # the list below if you'd like to provide any of the additional options
    # config.ignore_extensions []

    config.captcha_public_key = "6LcbvwsAAAAAACQjq3ZNqqBuDIHUR6gUthjhT9_Z"
    config.captcha_private_key = "6LcbvwsAAAAAALftkG9kwwqbPCeThnSOyn-TK8n5"

    # Your secret key for verifying cookie session data integrity.
    # If you change this key, all old sessions will become invalid!
    # Make sure the secret is at least 30 characters and all random,
    # no regular words or you'll be exposed to dictionary attacks.

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

    config.assets.enabled = true



    config.filter_parameters += [:password, :password_confirmation]

    # Use the database for sessions instead of the cookie-based default,
    # which shouldn't be used to store highly confidential information
    # (create the session table with 'rake db:sessions:create')
    # config.action_controller.session_store = :cookie_store DEPRECATED

    # Activate observers that should always be running
    #config.active_record.observers = :user_action_observer

    # The internationalization framework can be changed to have another default locale (standard is :en) or more load paths.
    # All files from config/locales/*.rb,yml are added automatically.
    # config.i18n.load_path << Dir[File.join(Rails.root, 'my', 'locales', '*.{rb,yml}')]
    # config.i18n.default_locale = :'en'

    # Make Active Record use UTC-base instead of local time
    config.time_zone = 'UTC'

    # Set the default field error proc
    config.action_view.field_error_proc = Proc.new do |html, instance|
      if html !~ /label/
        %{<span class="error-with-fieldxxxx">#{html} <span class="error">#{[instance.error_message].flatten.first}</span></span>}.html_safe
      else
        html
      end
    end

    config.after_initialize do
      extension_loader.load_extensions
      extension_loader.load_extension_initalizers

      #Dir["#{TRUSTY_CMS_ROOT}/config/initializers/**/*.rb"].sort.each do |initializer|
      #  load(initializer)
      #end

      extension_loader.activate_extensions  # also calls initialize_views
      #config.add_controller_paths(extension_loader.paths(:controller))
      #config.add_eager_load_paths(extension_loader.paths(:eager_load))

      # Add new inflection rules using the following format:
      ActiveSupport::Inflector.inflections do |inflect|
        inflect.uncountable 'config'
      end

      # TODO: Remove in 1.0
      #Savon.configure do |savon_config|
      #  savon_config.log = false
      #  savon_config.env_namespace = :soap
      #end
      #HTTPI.log = false

    end
  end
end
