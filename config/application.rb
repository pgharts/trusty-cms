require File.expand_path('boot', __dir__)

require 'rails/all'
require 'acts_as_tree'
require 'configuration_extensions/configuration_extensions'
require 'radius'
require 'trusty_cms/extension_loader'
require 'trusty_cms/initializer'
require 'rack/cache'
require 'trustygems'
require 'devise'

if defined?(Bundler)
  Bundler.require(*Rails.groups(assets: %w(development test)))
end

module TrustyCms
  class Application < Rails::Application
    include TrustyCms::Initializer
    config.active_record.whitelist_attributes = true
    config.autoload_paths += %W(#{config.root}/lib)
    config.eager_load_paths << Rails.root.join('lib')

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # Initialize extension paths
    config.initialize_extension_paths
    extension_loader = ExtensionLoader.instance { |l| l.initializer = self }
    extension_loader.paths(:load).reverse_each do |path|
      config.autoload_paths.unshift path
      $LOAD_PATH.unshift path
    end
    paths['app/helpers'] = []
    # config.add_plugin_paths(extension_loader.paths(:plugin))
    trusty_locale_paths = Dir[File.join(TRUSTY_CMS_ROOT, 'config', 'locales', '*.{rb,yml}')]
    config.i18n.load_path = trusty_locale_paths + extension_loader.paths(:locale)
    I18n.enforce_available_locales = true

    config.encoding = 'utf-8'

    config.middleware.use Rack::Cache,
                          private_headers: ['Authorization'],
                          entitystore: 'trusty:tmp/cache/entity',
                          metastore: 'trusty:tmp/cache/meta',
                          verbose: false,
                          allow_reload: false,
                          allow_revalidate: false
    config.middleware.insert_before(Rack::ConditionalGet, Rack::Cache)
    config.assets.enabled = true

    config.filter_parameters += %i[password password_confirmation]

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

      extension_loader.activate_extensions # also calls initialize_views
      # config.add_controller_paths(extension_loader.paths(:controller))
      # config.add_eager_load_paths(extension_loader.paths(:eager_load))

      # Add new inflection rules using the following format:
      ActiveSupport::Inflector.inflections do |inflect|
        inflect.uncountable 'config'
      end
    end
  end
end
