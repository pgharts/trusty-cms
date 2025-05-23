module TrustyCms
  class << self
    def config_definitions
      @config_definitions ||= {}
    end

    def config_definitions=(definitions)
      @config_definitions = definitions
    end
  end

  class Config < ActiveRecord::Base
    require 'trusty_cms/config/definition'
    #
    # The TrustyCms.config model class is stored in the database (and cached) but emulates a hash
    # with simple bracket methods that allow you to get and set values like so:
    #
    #   TrustyCms.config['setting.name'] = 'value'
    #   TrustyCms.config['setting.name'] #=> "value"
    #
    # Config entries can be used freely as general-purpose global variables unless a definition
    # has been given for that key, in which case restrictions and defaults may apply. The restrictions
    # can take the form of validations, requirements, permissions or permitted options. They are
    # declared by calling TrustyCms::Config#define:
    #
    #   # setting must be either 'foo', 'bar' or 'blank'
    #   define('admin.name', :select_from => ['foo', 'bar'])
    #
    #   # setting is (and must be) chosen from the names of currently available layouts
    #   define('shop.layout', :select_from => lambda { Layout.all.map{|l| [l.name,l.id]} }, :alow_blank => false)
    #
    #   # setting cannot be changed at runtime
    #   define('setting.important', :default => "something", :allow_change => false)
    #
    # Which almost always happens in a block like this:
    #
    #   TrustyCms.config do |config|
    #     config.namespace('user', :allow_change => true) do |user|
    #       user.define 'allow_password_reset?', :default => true
    #     end
    #   end
    #
    # or in an extension. TrustyCms currently defines the following settings and makes them editable by
    # admin users on the site configuration page:
    #
    # admin.title               :: the title of the admin system
    # admin.subtitle            :: the subtitle of the admin system
    # defaults.page.parts       :: a comma separated list of default page parts
    # defaults.page.status      :: a string representation of the default page status
    # defaults.page.filter      :: the default filter to use on new page parts
    # defaults.page.fields      :: a comma separated list of the default page fields
    # defaults.snippet.filter   :: the default filter to use on new snippets
    # local.timezone            :: the timezone name (`rake -D time` for full list)
    #                              used to correct displayed times
    # page.edit.published_date? :: when true, shows the datetime selector
    #                              for published date on the page edit screen
    #
    # Helper methods are defined in ConfigurationHelper that will display config entry values
    # or edit fields:
    #
    #   # to display label and value, where label comes from looking up the config key in the active locale
    #   show_setting('admin.name')
    #
    #   # to display an appropriate checkbox, text field or select box with label as above:
    #   edit_setting('admin.name)
    #

    self.table_name = 'config'
    after_save :update_cache
    attr_reader :definition

    class ConfigError < RuntimeError; end

    class << self
      def [](key)
        if database_exists?
          if table_exists?
            unless TrustyCms::Config.cache_file_exists?
              TrustyCms::Config.ensure_cache_file
              TrustyCms::Config.initialize_cache
            end
            TrustyCms::Config.initialize_cache if TrustyCms::Config.stale_cache?
            config_cache = Rails.cache.read('TrustyCms::Config')
            config_cache ? config_cache[key] : nil
          end
        end
      end

      def []=(key, value)
        if database_exists?
          if table_exists?
            setting = where(key: key).first_or_initialize
            setting.value = value
          end
        end
      end

      def database_exists?
        ActiveRecord::Base.connection
      rescue ActiveRecord::NoDatabaseError
        false
      else
        true
      end

      def to_hash
        Hash[*all.map { |pair| [pair.key, pair.value] }.flatten]
      end

      def initialize_cache
        TrustyCms::Config.ensure_cache_file
        Rails.cache.write('TrustyCms::Config', TrustyCms::Config.to_hash)
        Rails.cache.write('TrustyCms.cache_mtime', File.mtime(cache_file))
        Rails.cache.silence!
      end

      def cache_file_exists?
        File.file?(cache_file)
      end

      def stale_cache?
        return true unless TrustyCms::Config.cache_file_exists?

        Rails.cache.read('TrustyCms.cache_mtime') != File.mtime(cache_file)
      end

      def ensure_cache_file
        FileUtils.mkpath(cache_path)
        FileUtils.touch(cache_file)
      end

      def cache_path
        "#{Rails.root}/tmp"
      end

      def cache_file
        File.join(cache_path, 'trusty_config_cache.txt')
      end

      def site_settings
        @site_settings ||= %w{site.title site.host local.timezone}
      end

      def default_settings
        @default_settings ||= %w{defaults.locale defaults.page.filter defaults.page.parts defaults.page.fields defaults.page.status}
      end

      # A convenient drying method for specifying a prefix and options common to several settings.
      #
      #   TrustyCms.config do |config|
      #     config.namespace('secret', :allow_display => false) do |secret|
      #       secret.define('identity', :default => 'batman')      # defines 'secret.identity'
      #       secret.define('lair', :default => 'batcave')         # defines 'secret.lair'
      #       secret.define('longing', :default => 'vindication')  # defines 'secret.longing'
      #     end
      #   end
      #
      def namespace(prefix, options = {}, &block)
        prefix = [options[:prefix], prefix].join('.') if options[:prefix]
        with_options(options.merge(prefix: prefix), &block)
      end

      # Declares a setting definition that will constrain and support the use of a particular config entry.
      #
      #   define('setting.key', options)
      #
      # Can take several options:
      # * :default is the value that will be placed in the database if none has been set already
      # * :type can be :string, :boolean or :integer. Note that all settings whose key ends in ? are considered boolean.
      # * :select_from should be a list or hash suitable for passing to options_for_select, or a block that will return such a list at runtime
      # * :validate_with should be a block that will receive a value and return true or false. Validations are also implied by type or select_from.
      # * :allow_blank should be false if the config item must not be blank or nil
      # * :allow_change should be false if the config item can only be set, not changed. Add a default to specify an unchanging config entry.
      # * :allow_display should be false if the config item should not be showable in radius tags
      #
      #   TrustyCms.config do |config|
      #     config.define 'defaults.locale', :select_from => lambda { TrustyCms::AvailableLocales.locales }, :allow_blank => true
      #     config.define 'defaults.page.parts', :default => "Body,Extended"
      #     ...
      #   end
      #
      # It's also possible to reuse a definition by passing it to define:
      #
      #   choose_layout = TrustyCms::Config::Definition.new(:select_from => lambda {Layout.all.map{|l| [l.name, l.d]}})
      #   define "my.layout", choose_layout
      #   define "your.layout", choose_layout
      #
      # but at the moment that's only done in testing.
      #
      def define(key, options = {})
        called_from = caller.grep(/\/initializers\//).first
        if options.is_a? TrustyCms::Config::Definition
          definition = options
        else
          key = [options[:prefix], key].join('.') if options[:prefix]
        end

        definition ||= TrustyCms::Config::Definition.new(options.merge(definer: called_from))
        definitions[key] = definition

        if self[key].nil? && !definition.default.nil?
          begin
            self[key] = definition.default
          rescue ActiveRecord::RecordInvalid
            raise LoadError, "Default configuration invalid: value '#{definition.default}' is not allowed for '#{key}'"
          end
        end
      end

      def definitions
        TrustyCms.config_definitions
      end

      def definition_for(key)
        definitions[key] ||= TrustyCms::Config::Definition.new(empty: true)
      end
    end

    # The usual way to use a config item:
    #
    #    TrustyCms.config['key'] = value
    #
    # is equivalent to this:
    #
    #   TrustyCms::Config.find_or_create_by_key('key').value = value
    #
    # Calling value= also applies any validations and restrictions that are found in the associated definition.
    # so this will raise a ConfigError if you try to change a protected config entry or a RecordInvalid if you
    # set a value that is not among those permitted.
    #
    def value=(param)
      newvalue = param.to_s
      if newvalue != self[:value]
        raise ConfigError, "#{key} cannot be changed" unless settable? || self[:value].blank?

        self[:value] = if boolean?
                         newvalue == '1' || newvalue == 'true' ? 'true' : 'false'
                       else
                         newvalue
                       end
        save!
      end
      self[:value]
    end

    # Requesting a config item:
    #
    #    key = TrustyCms.config['key']
    #
    # is equivalent to this:
    #
    #   key = TrustyCms::Config.find_or_create_by_key('key').value
    #
    # If the config item is boolean the response will be true or false. For items with :type => :integer it will be an integer,
    # for everything else a string.
    #
    def value
      if boolean?
        checked?
      else
        self[:value]
      end
    end

    # Returns the definition associated with this config item. If none has been declared this will be an empty definition
    # that does not restrict use.
    #
    def definition
      @definition ||= self.class.definition_for(key)
    end

    # Returns true if the item key ends with '?' or the definition specifies :type => :boolean.
    #
    def boolean?
      definition.boolean? || key.ends_with?('?')
    end

    # Returns true if the item is boolean and true.
    #
    def checked?
      return nil if self[:value].nil?

      boolean? && self[:value] == 'true'
    end

    # Returns true if the item defintion includes a :select_from parameter that limits the range of permissible options.
    #
    def selector?
      definition.selector?
    end

    # Returns a name corresponding to the current setting value, if the setting definition includes a select_from parameter.
    #
    def selected_value
      definition.selected(value)
    end

    def update_cache
      TrustyCms::Config.initialize_cache
    end

    delegate :default, :type, :allow_blank?, :hidden?, :visible?, :settable?, :selection, :notes, :units, to: :definition

    def validate
      definition.validate(self)
    end
  end
end
