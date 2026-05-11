require 'trusty_cms/geometry'

class Asset < ActiveRecord::Base
  has_many :page_attachments, dependent: :destroy
  has_many :pages, through: :page_attachments
  has_site if respond_to? :has_site

  belongs_to :created_by, class_name: 'User'
  belongs_to :updated_by, class_name: 'User'

  default_scope { order('created_at DESC') }

  scope :latest, lambda { |limit|
    order('created_at DESC').limit(limit)
  }

  scope :of_types, lambda { |types|
    mimes = AssetType.slice(*types).map(&:mime_types).flatten
    return none if mimes.empty?
    
    joins(asset_attachment: :blob).where(active_storage_blobs: { content_type: mimes })
  }

  scope :matching, lambda { |term|
    joins(asset_attachment: :blob).where(['LOWER(active_storage_blobs.filename) LIKE (:term) OR LOWER(title) LIKE (:term) OR LOWER(caption) LIKE (:term)', { term: "%#{term.downcase}%" }])
  }

  scope :excepting, lambda { |assets|
    if assets.any?
      assets = assets.split(',') if assets.is_a?(String)
      asset_ids = assets.first.is_a?(Asset) ? assets.map(&:id) : assets
      where(["assets.id NOT IN(#{asset_ids.map { '?' }.join(',')})", *asset_ids])
    else
      {}
    end
  }

  def self.approved_content_types
    AssetType.known_mimetypes
  end

  has_one_attached :asset
  validates :asset, presence: true
  validate :asset_within_configured_size, if: -> { asset.attached? }
  validate :approved_content_type, if: -> { asset.attached? }
  before_validation :sync_attachment_metadata
  before_save :assign_title
  before_save :assign_uuid

  def asset_within_configured_size
    limit_mb =
      if video_content_type?
        TrustyCms.config['assets.max_video_size'].to_i
      else
        TrustyCms.config['assets.max_asset_size'].to_i
      end

    limit_bytes = limit_mb.megabytes
    return if asset.blob.byte_size.between?(1, limit_bytes)

    errors.add(:asset, :wrong_size_error, limit_mb: limit_mb)
  end

  def asset_type
    AssetType.for(asset)
  end

  def filename
    return asset.filename.to_s if asset.attached?

    self[:asset_file_name]
  end

  def content_type
    return asset.content_type if asset.attached?

    self[:asset_content_type]
  end

  def byte_size
    return asset.blob.byte_size if asset.attached?

    self[:asset_file_size]
  end

  delegate :active_storage_styles, :style_dimensions, :style_format,
           to: :asset_type

  def thumbnail(style_name = 'normal')
    return rewrite_cloud_url(asset.url) if asset.attached? && content_type == 'application/pdf'

    variant = asset_variant(style_name.to_s)
    return rewrite_cloud_url(variant.processed.url) if variant

    asset_type.icon(style_name.to_s)
  end

  def public_url(style_name = 'normal')
    if style_name.to_s == 'original' || render_original(style_name)
      return rewrite_cloud_url(asset.url)
    end

    variant = asset_variant(style_name.to_s)
    return rewrite_cloud_url(variant.processed.url) if variant

    rewrite_cloud_url(asset.url)
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[asset_content_type asset_file_name asset_file_size caption created_at created_by_id id original_extension original_height original_width title updated_at updated_by_id uuid]
  end

  def render_original(_style_name)
    return false unless asset.attached?

    prefix = TrustyCms::Config['assets.storage.prefix'].presence
    prefix ? asset.key.start_with?(prefix) : asset.key.include?('/')
  end

  def asset_variant(style_name)
    style = active_storage_styles[style_name.to_sym]
    return unless style

    transformations = active_storage_transformations(style[:geometry])
    transformations[:format] = style[:format] if style[:format]
    if asset.variable?
      asset.variant(transformations)
    elsif asset.previewable?
      asset.preview(transformations)
    end
  end

  def style?(style_name = 'original')
    style_name == 'original' || active_storage_styles.keys.include?(style_name.to_sym)
  end

  def basename
    File.basename(filename, '.*') if filename
  end

  def extension(style_name = 'original')
    if style_name == 'original'
      original_extension
    elsif style = active_storage_styles[style_name.to_sym]
      style[:format]
    else
      original_extension
    end
  end

  def original_extension
    return filename.split('.').last.downcase if filename
  end

  def attached_to?(page)
    pages.include?(page)
  end

  def original_geometry
    @original_geometry ||= TrustyCms::Geometry.new(*original_dimensions)
  end

  def geometry(style_name = 'original')
    unless style?(style_name)
      raise TrustyCms::StyleError,
            "Requested style #{style_name} is not defined for this asset."
    end

    @geometry ||= {}
    begin
      @geometry[style_name] ||= if style_name.to_s == 'original'
                                  original_geometry
                                else
                                  style = active_storage_styles[style_name.to_sym]
                                  original_geometry.transformed_by(style[:geometry])
                                  # this can return dimensions for fully specified style sizes but not for relative sizes when there are no original dimensions
                                end
    rescue TrustyCms::TransformationError => e
      Rails.logger.warn "geometry transformation error: #{e}"
      original_geometry # returns a blank geometry if the real geometry cannot be calculated
    end
  end

  def aspect(style_name = 'original')
    geometry(style_name).aspect
  end

  def orientation(style_name = 'original')
    a = aspect(style_name)
    if a == nil?
      'unknown'
    elsif a < 1.0
      'vertical'
    elsif a > 1.0
      'horizontal'
    else
      'square'
    end
  end

  def width(style_name = 'original')
    geometry(style_name).width.to_i
  end

  def height(style_name = 'original')
    geometry(style_name).height.to_i
  end

  def square?(style_name = 'original')
    geometry(style_name).square?
  end

  def vertical?(style_name = 'original')
    geometry(style_name).vertical?
  end

  def horizontal?(style_name = 'original')
    geometry(style_name).horizontal?
  end

  def dimensions_known?
    original_dimensions.all?(&:positive?)
  end

  private

  def original_dimensions
    width = original_width.presence
    height = original_height.presence
    if asset.attached?
      width ||= asset.metadata[:width] || asset.metadata['width']
      height ||= asset.metadata[:height] || asset.metadata['height']
    end
    [width.to_i, height.to_i]
  end

  def active_storage_transformations(geometry)
    return {} unless geometry.present?

    parsed = TrustyCms::Geometry.parse(geometry)
    width = parsed.width.positive? ? parsed.width : nil
    height = parsed.height.positive? ? parsed.height : nil
    return {} unless width && height

    case parsed.modifier
    when '#', '^', '!'
      { resize_to_fill: [width, height].compact }
    when '>', '<'
      { resize_to_limit: [width, height].compact }
    else
      { resize_to_limit: [width, height].compact }
    end
  end

  def video_content_type?
    AssetType.known?(:video) && AssetType.find(:video).mime_types.include?(content_type)
  end

  def approved_content_type
    return if Asset.approved_content_types.include?(asset.content_type)

    errors.add(:asset, :content_type, filename: asset.filename.to_s)
  end

  def sync_attachment_metadata
    return unless asset.attached?

    self.asset_file_name = asset.filename.to_s
    self.asset_content_type = asset.content_type
    self.asset_file_size = asset.blob.byte_size
    self.original_extension = asset.filename.extension&.downcase
    if asset.metadata[:width].present? && asset.metadata[:height].present?
      self.original_width = asset.metadata[:width]
      self.original_height = asset.metadata[:height]
    end
  end

  def assign_title
    return unless asset.attached?
    
    self.title = asset.filename.base
  end

  def assign_uuid
    self.uuid = SecureRandom.uuid unless uuid?
  end

  def rewrite_cloud_url(url)
    return url unless defined?(TrustyCmsClippedExtension::Cloud)

    TrustyCmsClippedExtension::Cloud.rewrite_url(url)
  end

  class << self
    def known_types
      AssetType.known_types
    end

    # searching and pagination moved to the controller

    def find_all_by_asset_types(asset_types, *args)
      with_asset_types(asset_types) { where *args }
    end

    def count_with_asset_types(asset_types, *args)
      with_asset_types(asset_types) { where(*args).count }
    end

    def with_asset_types(asset_types, &block)
      w_asset_types = AssetType.conditions_for(asset_types)
      with_scope(where(conditions: ["#{w_asset_types} = ?", block]))
    end
  end

  # called from AssetType to set type_condition? methods on Asset
  def self.define_class_method(name, &block)
    eigenclass.send :define_method, name, &block
  end

  # returns the return value of class << self block, which is self (as defined within that block)
  def self.eigenclass
    class << self
      self;
    end
  end

  # for backwards compatibility
  def self.thumbnail_sizes
    AssetType.find(:image).active_storage_styles
  end

  def self.thumbnail_names
    thumbnail_sizes.keys
  end

  # this is a convenience for image-pickers
  def self.thumbnail_options
    asset_sizes = thumbnail_sizes.map do |k, v|
      size_id = k
      size_description = "#{k}: "
      size_description << (v.is_a?(Array) ? v.join(' as ') : v)
      [size_description, size_id]
    end.sort_by { |pair| pair.last.to_s }
    asset_sizes.unshift ['Original (as uploaded)', 'original']
    asset_sizes
  end
end
