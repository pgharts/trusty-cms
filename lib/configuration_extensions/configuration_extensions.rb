module TrustyCms
  autoload :Cache, 'rack/cache'

  class << self
    # Returns the TrustyCms::Config eigenclass object, so it can be used wherever you would use TrustyCms::Config.
    #
    #   TrustyCms.config['site.title']
    #   TrustyCms.config['site.url'] = 'example.com'
    #
    # but it will also yield itself to a block:
    #
    #   TrustyCms.config do |config|
    #     config.define 'something', default => 'something'
    #     config['other.thing'] = 'nothing'
    #   end
    #
    def config  # method must be defined before any initializers run
      yield TrustyCms::Config if block_given?
      TrustyCms::Config
    end

    # Returns the configuration object with which this application was initialized.
    # For now it's exactly the same as calling Rails.configuration except that it will also yield itself to a block.
    #
    def configuration
      yield Rails.configuration if block_given?
      Rails.configuration
    end

    # Returns the root directory of this radiant installation (which is usually the gem directory).
    # This is not the same as Rails.root, which is the instance directory and tends to contain only site-delivery material.
    #
    def root
      Pathname.new(TRUSTY_CMS_ROOT) if defined?(TRUSTY_CMS_ROOT)
    end
    def boot!
      unless booted?
        preinitialize
        pick_boot.run
      end
    end

    def booted?
      defined? TrustyCms::Initializer
    end

    def pick_boot
      case
        when app?
          AppBoot.new
        when vendor?
          VendorBoot.new
        else
          GemBoot.new
      end
    end

    def vendor?
      File.exist?("#{Rails.root}/vendor/radiant")
    end

    def app?
      File.exist?("#{Rails.root}/lib/trusty_cms.rb")
    end

    def preinitialize
      load(preinitializer_path) if File.exist?(preinitializer_path)
    end

    def loaded_via_gem?
      pick_boot.is_a? GemBoot
    end

    def preinitializer_path
      "#{Rails.root}/config/preinitializer.rb"
    end
  end
end


class Rails::Application::Configuration

  # The TrustyCms::Configuration class extends Rails::Configuration with three purposes:
  # * to reset some rails defaults so that files are found in TRUSTY_CMS_ROOT instead of Rails.root
  # * to notice that some gems and plugins are in fact radiant extensions
  # * to notice that some radiant extensions add load paths (for plugins, controllers, metal, etc)

  attr_accessor :extension_paths, :ignored_extensions

  def initialize_extension_paths
    self.extension_paths = default_extension_paths
    self.ignored_extensions = []
  end

  # Sets the locations in which we look for vendored extensions. Normally:
  #   Rails.root/vendor/extensions
  #   TrustyCms.root/vendor/extensions
  # There are no vendor/* directories in +TRUSTY_CMS_ROOT+ any more but the possibility remains for compatibility reasons.
  # In test mode we also add a fixtures path for testing the extension loader.
  #
  def default_extension_paths
    env = ENV["RAILS_ENV"] || Rails.env
    paths = [Rails.root + 'vendor/extensions']
    paths.unshift(TRUSTY_CMS_ROOT + "/vendor/extensions") unless Rails.root == TRUSTY_CMS_ROOT
    paths.unshift(TRUSTY_CMS_ROOT + "test/fixtures/extensions") if env =~ /test/
    paths
  end

  # The list of extensions, expanded and in load order, that results from combining all the extension
  # configuration directives. These are the extensions that will actually be loaded or migrated,
  # and for most purposes this is the list you want to refer to.
  #
  #   TrustyCms.configuration.enabled_extensions  # => [:name, :name, :name, :name]
  #
  # Note that an extension enabled is not the same as an extension activated or even loaded: it just means
  # that the application is configured to load that extension.
  #
  def enabled_extensions
    @enabled_extensions ||= expanded_extension_list - ignored_extensions
  end

  # The expanded and ordered list of extensions, including any that may later be ignored. This can be configured
  # (it is here that the :all entry is expanded to mean 'everything else'), or will default to an alphabetical list
  # of every extension found among gems and vendor/extensions directories.
  #
  #   TrustyCms.configuration.expanded_extension_list  # => [:name, :name, :name, :name]
  #
  # If an extension in the configurted list is not found, a LoadError will be thrown from here.
  #
  def expanded_extension_list
    # NB. it should remain possible to say config.extensions = []
    @extension_list ||= extensions ? expand_and_check(extensions) : available_extensions
  end

  def expand_and_check(extension_list) #:nodoc
    missing_extensions = extension_list - [:all] - available_extensions
    raise LoadError, "These configured extensions have not been found: #{missing_extensions.to_sentence}" if missing_extensions.any?
    if m = extension_list.index(:all)
      extension_list[m] = available_extensions - extension_list
    end
    extension_list.flatten
  end

  # Returns the checked and expanded list of extensions-to-enable. This may be derived from a list passed to
  # +config.extensions=+ or it may have defaulted to all available extensions.

  # Without such a call, we default to the alphabetical list of all well-formed vendor and gem extensions
  # returned by +available_extensions+.
  #
  #   TrustyCms.configuration.extensions  # => [:name, :all, :name]
  #
  def extensions
    @requested_extensions ||= available_extensions
  end

  # Sets the list of extensions that will be loaded and the order in which to load them.
  # It can include an :all marker to mean 'everything else' and is typically set in environment.rb:
  #   config.extensions = [:layouts, :taggable, :all]
  #   config.extensions = [:dashboard, :blog, :all]
  #   config.extensions = [:dashboard, :blog, :all, :comments]
  #
  # A LoadError is raised if any of the specified extensions can't be found.
  #
  def extensions=(extensions)
    @requested_extensions = extensions
  end

  # This is a configurable list of extension that should not be loaded.
  #   config.ignore_extensions = [:experimental, :broken]
  # You can also retrieve the list with +ignored_extensions+:
  #   TrustyCms.configuration.ignored_extensions  # => [:experimental, :broken]
  # These exclusions are applied regardless of dependencies and extension locations. A configuration that bundles
  # required extensions then ignores them will not boot and is likely to fail with errors about unitialized constants.
  #
  def ignore_extensions(array)
    self.ignored_extensions |= array
  end

  # Returns an alphabetical list of every extension found among all the load paths and bundled gems. Any plugin or
  # gem whose path ends in the form +radiant-something-extension+ is considered to be an extension.
  #
  #   TrustyCms.configuration.available_extensions  # => [:name, :name, :name, :name]
  #
  # This method is always called during initialization, either as a default or to check that specified extensions are
  # available. One of its side effects is to populate the ExtensionLoader's list of extension root locations, later
  # used when activating those extensions that have been enabled.
  #
  def available_extensions
    @available_extensions ||= (vendored_extensions + gem_extensions).uniq.sort.map(&:to_sym)
  end

  # Searches the defined extension_paths for subdirectories and returns a list of names as symbols.
  #
  #   TrustyCms.configuration.vendored_extensions  # => [:name, :name]
  #
  def vendored_extensions
    extension_paths.each_with_object([]) do |load_path, found|
      Dir["#{load_path}/*"].each do |path|
        if File.directory?(path)
          ep = TrustyCms::ExtensionLoader.record_path(path)
          found << ep.name
        end
      end
    end
  end

  # Scans the bundled gems for any whose name match the +radiant-something-extension+ format
  # and returns a list of their names as symbols.
  #
  #   TrustyCms.configuration.gem_extensions  # => [:name, :name]
  #
  def gem_extensions
    Gem.loaded_specs.each_with_object([]) do |(gemname, gemspec), found|
      if gemname =~ /trusty-.*-extension$/
        ep = TrustyCms::ExtensionLoader.record_path(gemspec.full_gem_path, gemname)
        found << ep.name
      end
    end
  end

  # Old extension-dependency mechanism now deprecated
  #
  def extension(ext)
    ::ActiveSupport::Deprecation.warn("Extension dependencies have been deprecated and are no longer supported in radiant 1.0. Extensions with dependencies should be packaged as gems and use the .gemspec to declare them.", caller)
  end

  # Old gem-invogation method now deprecated
  #
  def gem(name, options = {})
    ::ActiveSupport::Deprecation.warn("Please declare gem dependencies in your Gemfile (or for an extension, in the .gemspec file).", caller)
    super
  end

  # Returns the AdminUI singleton, giving get-and-set access to the tabs and partial-sets it defines.
  # More commonly accessed in the initializer via its call to +configuration.admin+.
  #
  def admin
    TrustyCms::AdminUI.instance
  end

  private

  # Overrides the Rails::Initializer default to add plugin paths in TRUSTY_CMS_ROOT as well as Rails.root.
  #
  def default_plugin_paths
    super + ["#{TRUSTY_CMS_ROOT}/lib/plugins", "#{TRUSTY_CMS_ROOT}/vendor/plugins"]
  end

  # Overrides the Rails::Initializer default to look for views in TRUSTY_CMS_ROOT rather than Rails.root.
  #
  def default_view_path
    File.join(TRUSTY_CMS_ROOT, 'app', 'views')
  end

  # Overrides the Rails::Initializer default to look for controllers in TRUSTY_CMS_ROOT rather than Rails.root.
  #
  def default_controller_paths
    [File.join(TRUSTY_CMS_ROOT, 'app', 'controllers')]
  end
end


# TODO: Move all of this to a separate file.
class Boot
  def run
    load_mutex
    load_initializer
  end

  # RubyGems from version 1.6 does not require thread but Rails depend on it
  # This should newer rails do automaticly
  def load_mutex
    begin
      require "thread" unless defined?(Mutex)
    rescue LoadError => _
      $stderr.puts %(Mutex could not be initialized. #{load_error_message})
      exit 1
    end
  end

  def load_initializer
    begin
      require 'trusty_cms'
      require 'trusty_cms/initializer'
    rescue LoadError => _
      $stderr.puts %(TrustyCms could not be initialized. #{load_error_message})
      exit 1
    end
    TrustyCms::Initializer.run(:set_load_path)
    TrustyCms::Initializer.run(:install_gem_spec_stubs)
    Rails::GemDependency.add_frozen_gem_path
  end
end

class VendorBoot < Boot
  def load_initializer
    $LOAD_PATH.unshift "#{Rails.root}/vendor/trusty_cms/lib"
    super
  end

  def load_error_message
    "Please verify that vendor/radiant contains a complete copy of the TrustyCms sources."
  end
end

class AppBoot < Boot
  def load_initializer
    $LOAD_PATH.unshift "#{Rails.root}/lib"
    super
  end

  def load_error_message
    "Please verify that you have a complete copy of the TrustyCms sources."
  end
end

class GemBoot < Boot
  # The location and version of the radiant gem should be set in your Gemfile
  def load_error_message
    "Have you run `bundle install`?'."
  end
end
