class AssetType
  # The Asset Type encapsulates a type of attachment.
  # Conventionally this would a sensible category like 'image' or 'video'
  # that should be processed and presented in a particular way.
  # An AssetType currently provides:
  #   * processing and variant definitions for ActiveStorage
  #   * mime type list for file recognition
  #   * selectors and scopes for retrieving this (or not this) category of asset
  #   * radius tags for those subsets of assets (temporarily removed pending discussion of interface)

  @@types = []
  @@type_lookup = {}
  @@extension_lookup = {}
  @@mime_lookup = {}
  @@default_type = nil
  attr_reader :name, :processors, :styles, :icon_name, :catchall, :default_radius_tag

  def initialize(name, options = {})
    options = options.symbolize_keys
    @name = name
    @icon_name = options[:icon] || name
    @processors = options[:processors] || []
    @styles = options[:styles] || {}
    @styles = standard_styles if @styles == :standard
    @default_radius_tag = options[:default_radius_tag] || 'link'
    @extensions = options[:extensions] || []
    @extensions.each { |ext| @@extension_lookup[ext] ||= self }
    @mimes = options[:mime_types] || []
    @mimes.each { |mimetype| @@mime_lookup[mimetype] ||= self }

    this = self
    Asset.send :define_method, "#{name}?".intern do this.mime_types.include?(content_type) end
    Asset.send :define_class_method, "#{name}_condition".intern do this.condition; end
    Asset.send :define_class_method, "not_#{name}_condition".intern do this.non_condition; end
    Asset.send :scope, plural.to_sym, -> { where(conditions: condition) }
    Asset.send :scope, "not_#{plural}".to_sym, -> { where(conditions: non_condition) }

    define_radius_tags
    @@types.push self
    @@type_lookup[@name] = self
  end

  def plural
    name.to_s.pluralize
  end

  def icon(style_name = 'icon')
    if File.exist?(Rails.root + "public/images/admin/assets/#{icon_name}_#{style_name}.png")
      "/assets/admin/#{icon_name}_#{style_name}.png"
    else
      "/assets/admin/#{icon_name}_icon.png"
    end
  end

  def icon_path(style_name = 'icon')
    Rails.root + "public#{icon(style_name)}"
  end

  def condition
    if @mimes.any?
      ["asset_content_type IN (#{@mimes.map { '?' }.join(',')})", *@mimes]
    else
      self.class.other_condition
    end
  end

  def sanitized_condition
    ActiveRecord::Base.send :sanitize_sql_array, condition
  end

  def non_condition
    if @mimes.any?
      ["NOT asset_content_type IN (#{@mimes.map { '?' }.join(',')})", *@mimes]
    else
      self.class.non_other_condition
    end
  end

  def sanitized_non_condition
    ActiveRecord::Base.send :sanitize_sql_array, non_condition
  end

  def mime_types
    @mimes
  end

  def processing_enabled?
    TrustyCms.config["assets.create_#{name}_thumbnails?"]
  end

  # Parses and combines the various ways in which ActiveStorage styles can be defined, and normalises them into
  # the format that ActiveStorage expects. Note that :styles => :standard has already been replaced with the
  # results of a call to standard_styles.
  # Styles are passed as a hash and arbitrary keys can be passed through from configuration.
  #
  def active_storage_styles
    @active_storage_styles ||= if processing_enabled?
                                 normalize_style_rules(configured_styles.merge(styles))
                               else
                                 {}
    end
    @active_storage_styles
  end

  # Takes a motley collection of differently-defined styles and renders them into the standard hash-of-hashes format.
  # Solitary strings are assumed to be  #
  def normalize_style_rules(styles = {})
    styles.each_pair do |name, rule|
      unless rule.is_a? Hash
        if rule =~ /\=/
          parameters = rule.split(',').collect { |parameter| parameter.split('=') } # array of pairs
          rule = Hash[parameters].symbolize_keys # into hash of :first => last
        else
          rule = { geometry: rule } # simplest case: name:geom|name:geom
        end
      end
      rule[:geometry] ||= rule.delete(:size)
      styles[name.to_sym] = rule
    end
    styles
  end

  def standard_styles
    {
      icon: { geometry: '50x50#', format: :png },
      thumbnail: { geometry: '100x100#', format: :png },
    }
  end

  # ActiveStorage styles are defined in the config entry `assets.thumbnails.asset_type`, with the format:
  # foo:key-x,key=y,key=z|bar:key-x,key=y,key=z
  # where 'key' can be any parameter understood by your variant processor. Usually they include :geometry and :format.
  # A typical entry would be:
  #
  #   standard:geometry=640x640>,format=jpg
  #
  # This method parses that string and returns the defined styles as a hash of style-defining strings that will later be normalized into hashes.
  #
  def configured_styles
    @configured_styles ||= if style_definitions = TrustyCms.config["assets.thumbnails.#{name}"]
                             style_definitions.split('|').each_with_object({}) do |definition, styles|
                               name, rule = definition.split(':')
                               styles[name.strip.to_sym] = rule.to_s.strip
                             end
                           else
                             {}
    end
  end

  def style_dimensions(style_name)
    if style = active_storage_styles[style_name.to_sym]
      style[:geometry]
    end
  end

  def style_format(style_name)
    if style = active_storage_styles[style_name.to_sym]
      style[:format]
    end
  end

  def define_radius_tags
    type = name
    Page.class_eval do
      tag "asset:if_#{type}" do |tag|
        tag.expand if find_asset(tag, tag.attr.dup).send("#{type}?".to_sym)
      end
      tag "asset:unless_#{type}" do |tag|
        tag.expand unless find_asset(tag, tag.attr.dup).send("#{type}?".to_sym)
      end
    end
  end

  # class methods

  def self.for(attachment)
    return catchall unless attachment&.attached?

    extension = attachment.blob&.filename&.extension&.downcase || attachment.record.original_extension
    from_extension(extension) || from_mimetype(attachment.blob&.content_type) || catchall
  end

  def self.from_extension(extension)
    @@extension_lookup[extension]
  end

  def self.from_mimetype(mimetype)
    @@mime_lookup[mimetype]
  end

  def self.catchall
    @@default_type ||= find(:other)
  end

  def self.known?(name)
    !find(name).nil?
  end

  def self.slice(*types)
    @@type_lookup.slice(*types.map(&:to_sym)).values if types # Hash#slice is provided by will_paginate
  end

  def self.find(type)
    @@type_lookup[type] if type
  end

  def self.[](type)
    find(type)
  end

  def self.all
    @@types
  end

  def self.known_types
    @@types.map(&:name) # to preserve order
  end

  def self.known_mimetypes
    @@mime_lookup.keys
  end

  def self.mime_types_for(*names)
    names.collect { |name| find(name).mime_types }.flatten
  end

  def self.conditions_for(*names)
    names.collect { |name| find(name).sanitized_condition }.join(' OR ')
  end

  def self.non_other_condition
    ["asset_content_type IN (#{known_mimetypes.map { '?' }.join(',')})", *known_mimetypes]
  end

  def self.other_condition
    ["NOT asset_content_type IN (#{known_mimetypes.map { '?' }.join(',')})", *known_mimetypes]
  end
end
