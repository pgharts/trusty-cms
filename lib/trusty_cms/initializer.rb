require 'will_paginate'
require 'rails'
require 'haml-rails'
require 'haml'
require 'mysql2'

require 'trusty_cms/admin_ui'
require 'trusty_cms/extension_loader'
require 'string_extensions/string_extensions'
require 'trusty_cms/engine'

# This is a wild and probably terrible hack built to initialize extension engines.
# I have no idea what the repercussions will be. Revisit later.
Gem.loaded_specs.each_with_object([]) do |(gemname, gemspec), found|
  if gemname =~ /trusty-.*-extension$/
    ep = TrustyCms::ExtensionLoader.record_path(gemspec.full_gem_path, gemname)
    require "#{ep.name}/engine"
  end
end

module TrustyCms

  module Initializer

    # Rails::Initializer is essentially a list of startup steps and we extend it here by:
    # * overriding or extending some of those steps so that they use radiant and extension paths
    #   as well as (or instead of) the rails defaults.
    # * appending some extra steps to set up the admin UI and activate extensions


    # Returns true in the very unusual case where radiant has been deployed as a rails app itself, rather than
    # loaded as a gem or from vendor/. This is only likely in situations where radiant is customised so heavily
    # that extensions are not sufficient.
    #
    def deployed_as_app?
      TRUSTY_CMS_ROOT == Rails.root
    end

    # Extends the Rails::Initializer default to add extension paths to the autoload list.
    # Note that +default_autoload_paths+ is also overridden to point to TRUSTY_CMS_ROOT.
    #
    def set_autoload_patf
      super
    end

    # Overrides the Rails initializer to load metal from TRUSTY_CMS_ROOT and from radiant extensions.
    #
    def initialize_metal
      Rails::Rack::Metal.requested_metals = configuration.metals
      Rails::Rack::Metal.metal_paths = ["#{TRUSTY_CMS_ROOT}/app/metal"] # reset Rails default to TRUSTY_CMS_ROOT
      Rails::Rack::Metal.metal_paths += plugin_loader.engine_metal_paths
      Rails::Rack::Metal.metal_paths += extension_loader.paths(:metal)
      Rails::Rack::Metal.metal_paths.uniq!

      configuration.middleware.insert_before(
        :"ActionController::ParamsParser",
        Rails::Rack::Metal, :if => Rails::Rack::Metal.metals.any?)
    end

    # Extends the Rails initializer to add locale paths from TRUSTY_CMS_ROOT and from radiant extensions.
    #
    def initialize_i18n
      radiant_locale_paths = Dir[File.join(TRUSTY_CMS_ROOT, 'config', 'locales', '*.{rb,yml}')]
      configuration.i18n.load_path = radiant_locale_paths + extension_loader.paths(:locale)
      super
    end

    # Extends the Rails initializer to add plugin paths in extensions
    # and makes extension load paths reloadable (eg in development mode)
    #
    def add_plugin_load_paths
      configuration.add_plugin_paths(extension_loader.paths(:plugin))
      super
      ActiveSupport::Dependencies.autoload_once_paths -= extension_loader.paths(:load)
    end

    # Overrides the standard gem-loader to use Bundler instead of config.gem. This is the method normally monkey-patched
    # into Rails::Initializer from boot.rb if you follow the instructions at http://gembundler.com/rails23.html
    #
    def load_gems
      @bundler_loaded ||= Bundler.require :default, Rails.env
    end

    # Extends the Rails initializer also to load radiant extensions (which have been excluded from the list of plugins).
    #
    def load_plugins
      super
      extension_loader.load_extensions
    end

    # Extends the Rails initializer to run initializers from radiant and from extensions. The load order will be:
    # 1. TRUSTY_CMS_ROOT/config/intializers/*.rb
    # 2. Rails.root/config/intializers/*.rb
    # 3. config/initializers/*.rb found in extensions, in extension load order.
    #
    # In the now rare case where radiant is deployed as an ordinary rails application, step 1 is skipped
    # because it is equivalent to step 2.
    #
    def load_application_initializers
      load_radiant_initializers unless deployed_as_app?
      super
      extension_loader.load_extension_initalizers
    end

    # Loads initializers found in TRUSTY_CMS_ROOT/config/initializers.
    #
    def load_radiant_initializers
      Dir["#{TRUSTY_CMS_ROOT}/config/initializers/**/*.rb"].sort.each do |initializer|
        load(initializer)
      end
    end

    # Extends the Rails initializer with some extra steps at the end of initialization:
    # * hook up radiant view paths in controllers and notifiers
    # * initialize the navigation tabs in the admin interface
    # * initialize the extendable partial sets that make up the admin interface
    # * call +activate+ on all radiant extensions
    # * add extension controller paths
    # * mark extension app paths for eager loading
    #
    def after_initialize
      super
      extension_loader.activate_extensions  # also calls initialize_views
      TrustyCms::Application.config.add_controller_paths(extension_loader.paths(:controller))
      TrustyCms::Application.config.add_eager_load_paths(extension_loader.paths(:eager_load))
    end

    # Initializes all the admin interface elements and views. Separate here so that it can be called
    # to reset the interface before extension (re)activation.
    #
    def initialize_views
      initialize_default_admin_tabs
      admin.load_default_regions
    end

    # Initializes the core admin tabs. Separate so that it can be invoked by itself in tests.
    #
    def initialize_default_admin_tabs
      admin.initialize_nav
    end

    # Extends the Rails initializer to make sure that extension controller paths are available when routes
    # are initialized.
    #
    def initialize_routing
      configuration.add_controller_paths(extension_loader.paths(:controller))
      configuration.add_eager_load_paths(extension_loader.paths(:eager_load))
      super
    end

    # Returns the TrustyCms::AdminUI singleton so that the initializer can set up the admin interface.
    #
    def admin
      TrustyCms::Application.config.admin
    end

    # Returns the ExtensionLoader singleton that will eventually load extensions.
    #
    def extension_loader
      ExtensionLoader.instance {|l| l.initializer = self }
    end

  end
end
