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
    Asset.select { |x| mimes.include?(x.asset_content_type) }
  }

  scope :matching, lambda { |term|
    where(['LOWER(assets.asset_file_name) LIKE (:term) OR LOWER(title) LIKE (:term) OR LOWER(caption) LIKE (:term)', { term: "%#{term.downcase}%" }])
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

  has_one_attached :asset
  validates :asset,
            presence: true,
            blob:
              {
                content_type: %w[application/zip image/jpg image/jpeg image/png image/gif application/pdf text/css],
                size_range: 1..5.megabytes,
              }
  before_save :assign_title
  before_save :assign_uuid

  def asset_type
    AssetType.for(asset)
  end
  delegate :paperclip_processors, :paperclip_styles, :active_storage_styles, :style_dimensions, :style_format,
           to: :asset_type

  def thumbnail(style_name = 'original')
    return asset.url if style_name == 'original'
    return asset_variant(style_name).processed.url if asset.variable?

    asset_type.icon(style_name)
  end

  def asset_variant(style_name)
    case style_name.to_s
    when 'thumbnail'
      asset.variant(gravity: 'Center', resize: '100x100^', crop: '100x100+0+0')
    when 'normal'
      asset.variant(gravity: 'Center', resize: '640x640^')
    when 'small'
      asset.variant(gravity: 'Center', resize: '320x320^')
    when 'icon'
      asset.variant(gravity: 'Center', resize: '50x50^')
    end
  end

  def style?(style_name = 'original')
    style_name == 'original' || paperclip_styles.keys.include?(style_name.to_sym)
  end

  def basename
    File.basename(asset_file_name, '.*') if asset_file_name
  end

  def extension(style_name = 'original')
    if style_name == 'original'
      original_extension
    elsif style = paperclip_styles[style_name.to_sym]
      style.format
    else
      original_extension
    end
  end

  def original_extension
    return asset_file_name.split('.').last.downcase if asset_file_name
  end

  def attached_to?(page)
    pages.include?(page)
  end

  def original_geometry
    @original_geometry ||= Paperclip::Geometry.new(original_width, original_height)
  end

  def geometry(style_name = 'original')
    unless style?(style_name)
      raise Paperclip::StyleError,
            "Requested style #{style_name} is not defined for this asset."
    end

    @geometry ||= {}
    begin
      @geometry[style_name] ||= if style_name.to_s == 'original'
                                  original_geometry
                                else
                                  style = asset.styles[style_name.to_sym]
                                  original_geometry.transformed_by(style.geometry)
                                  # this can return dimensions for fully specified style sizes but not for relative sizes when there are no original dimensions
                                end
    rescue Paperclip::TransformationError => e
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
    original_width? && original_height?
  end

  private

  # at this point the file queue will not have been written
  # but the upload should be in place. We read dimensions from the
  # original file and calculate thumbnail dimensions later, on demand.

  def read_dimensions
    if image? && file = asset.queued_for_write[:original]
      geometry = Paperclip::Geometry.from_file(file)
      self.original_width = geometry.width
      self.original_height = geometry.height
      self.original_extension = File.extname(file.path)
    end
    true
  end

  def assign_title
    self.title = asset.filename.base
  end

  def assign_uuid
    self.uuid = UUIDTools::UUID.timestamp_create.to_s unless uuid?
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
    class << self; self; end
  end

  # for backwards compatibility
  def self.thumbnail_sizes
    AssetType.find(:image).paperclip_styles
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
