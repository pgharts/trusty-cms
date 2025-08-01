require 'trusty_cms/taggable'

class Page < ActiveRecord::Base
  class MissingRootPageError < StandardError
    def initialize(message = 'Database missing root page')
      ; super
    end
  end

  # Callbacks
  before_save :update_virtual,
              :update_published_datetime,
              :set_allowed_children_cache,
              :handle_hidden_status

  # Associations
  acts_as_tree order: 'position ASC'
  has_many :parts, -> { order(:id) }, class_name: 'PagePart', foreign_key: :page_id, autosave: true, dependent: :destroy
  accepts_nested_attributes_for :parts, allow_destroy: true
  has_many :fields, -> { order(:id) }, class_name: 'PageField', foreign_key: :page_id, autosave: true, dependent: :destroy
  accepts_nested_attributes_for :fields, allow_destroy: true
  belongs_to :layout
  belongs_to :created_by, class_name: 'User'
  belongs_to :updated_by, class_name: 'User'

  has_paper_trail

  # Validations
  validates_presence_of :title, :slug, :breadcrumb, :status_id

  validates_length_of :title, maximum: 255
  validates_length_of :slug, maximum: 100
  validates_length_of :breadcrumb, maximum: 160

  validates_format_of :slug, with: %r{\A([-_.A-Za-z0-9]*|/)\z}
  validates_uniqueness_of :slug, scope: :parent_id

  validate :valid_class_name

  include TrustyCms::Taggable
  include StandardTags
  include Annotatable

  annotate :description
  attr_accessor :request, :response, :pagination_parameters

  class_attribute :default_child
  self.default_child = self

  self.inheritance_column = 'class_name'

  def layout_with_inheritance
    if layout_without_inheritance
      layout_without_inheritance
    else
      parent.layout if parent?
    end
  end

  alias_method :layout_without_inheritance, :layout
  alias_method :layout, :layout_with_inheritance

  def description
    self['description']
  end

  def description=(value)
    self['description'] = value
  end

  def cache?
    true
  end

  def child_path(child)
    clean_path(path + '/' + child.slug)
  end

  alias_method :child_url, :child_path

  def part(name)
    if new_record? || parts.to_a.any?(&:new_record?)
      parts.to_a.find { |p| p.name == name.to_s }
    else
      parts.find_by_name name.to_s
    end
  end

  def part?(name)
    !part(name).nil?
  end

  def has_or_inherits_part?(name)
    part?(name) || inherits_part?(name)
  end

  def inherits_part?(name)
    !part?(name) && ancestors.any? { |page| page.part?(name) }
  end

  def field(name)
    if new_record? || fields.any?(&:new_record?)
      fields.detect { |f| f.name.downcase == name.to_s.downcase }
    else
      fields.find_by_name name.to_s
    end
  end

  def published?
    status == Status[:published]
  end

  def hidden?
    status == Status[:hidden]
  end

  def scheduled?
    status == Status[:scheduled]
  end

  def status
    Status.find(status_id)
  end

  def status=(value)
    self.status_id = value.id
  end

  def path
    return '' if slug.blank?

    parent.present? ? clean_path("#{parent.path}/#{slug}") : clean_path(slug)
  end

  alias_method :url, :path

  def process(request, response)
    @request = request
    @response = response
    set_response_headers(@response)
    @response.body = render
    @response.status = response_code
  end

  def headers
    # Return a blank hash that child classes can override or merge
    {}
  end

  def set_response_headers(response)
    set_content_type(response)
    headers.each { |k, v| response.headers[k] = v }
  end

  def self.save_order(new_position)
    dictionary = Hash[*new_position.flatten(1)]
    dictionary.each do |id, position|
      page = Page.find_by_id(id)
      page.position = position if page.position.present?
      page.save
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    ['site_id', 'title', 'slug']
  end

  def self.parent_pages(homepage_id)
    where(parent_id: homepage_id).or(where(id: homepage_id))
  end

  private :set_response_headers

  def set_content_type(response)
    if layout
      content_type = layout.content_type.to_s.strip
      if content_type.present?
        response.headers['Content-Type'] = content_type
      end
    end
  end

  private :set_content_type

  def response_code
    200
  end

  def render
    if layout
      parse_object(layout)
    else
      render_part(:body)
    end
  end

  def render_part(part_name)
    part = part(part_name)
    if part
      parse_object(part)
    else
      ''
    end
  end

  def render_snippet(snippet)
    parse_object(snippet)
  end

  def find_by_path(path, can_view_drafts = false, clean = true)
    return nil if virtual?

    path = clean_path(path) if clean
    my_path = self.path
    if (my_path == path) && (published? || hidden? || can_view_drafts)
      return self
    elsif path =~ /^#{Regexp.quote(my_path)}([^\/]*)/
      slug_child = children.find_by_slug($1)
      if slug_child
        found = slug_child.find_by_path(path, can_view_drafts, clean)
        return found if found
      end
      children.each do |child|
        found = child.find_by_path(path, can_view_drafts, clean)
        return found if found
      end
    end

    unless slug_child
      file_not_found_types = ([FileNotFoundPage] + FileNotFoundPage.descendants)
      file_not_found_names = file_not_found_types.collect { |x| x.name }
      condition = (['class_name = ?'] * file_not_found_names.length).join(' or ')
      condition = "status_id = #{Status[:published].id} and (#{condition})" unless can_view_drafts
      return children.where([condition] + file_not_found_names).first
    end
    slug_child
  end

  def update_published_datetime
    self.published_at = Time.zone.now if published? && published_at.blank?
  end

  def default_child
    self.class.default_child
  end

  def allowed_children_lookup
    [default_child, *Page.descendants.sort_by(&:name)].uniq
  end

  def set_allowed_children_cache
    self.allowed_children_cache = allowed_children_lookup.collect(&:name).join(',')
  end

  def handle_hidden_status
    return unless status_id == Status[:hidden].id
    return unless TrustyCms::Application.config.on_hidden_callback

    TrustyCms::Application.config.on_hidden_callback.call(self)
  end

  class << self
    def root
      find_by_parent_id(nil)
    end

    def find_by_path(path, can_view_drafts = false)
      raise MissingRootPageError unless root

      root.find_by_path(path, can_view_drafts)
    end

    def date_column_names
      columns.collect { |c| c.name if c.sql_type =~ /(date|time)/ }.compact
    end

    def display_name(string = nil)
      if string
        @display_name = string
      else
        @display_name ||= begin
          n = name.to_s
          n.sub(/^(.+?)Page$/, '\1')
          n.gsub(/([A-Z])/, ' \1')
          n.strip
        end
      end
      @display_name = @display_name + ' - not installed' if missing? && @display_name !~ /not installed/
      @display_name
    end

    def display_name=(string)
      display_name(string)
    end

    def load_subclasses
      ([TRUSTY_CMS_ROOT] + TrustyCms::Extension.descendants.map(&:root)).each do |path|
        Dir["#{path}/app/models/*_page.rb"].each do |page|
          $1.camelize.constantize if page =~ %r{/([^/]+)\.rb}
        end
      end
      if database_exists?
        if ActiveRecord::Base.connection.data_sources.include?('pages') && Page.column_names.include?('class_name') # Assume that we have bootstrapped
          Page.connection.select_values("SELECT DISTINCT class_name FROM pages WHERE class_name <> '' AND class_name IS NOT NULL").each do |p|
            begin
              p.constantize
            rescue NameError, LoadError
              # Rubocop: The use of eval is a serious security risk.
              # eval(%Q{class #{p} < Page; acts_as_tree; def self.missing?; true end end}, TOPLEVEL_BINDING)
              Rails.logger.error NameError
            end
          end
        end
      end
    end

    def new_with_defaults(config = TrustyCms::Config)
      page = new
      page.parts.concat default_page_parts(config)
      page.fields.concat default_page_fields(config)
      default_status = config['defaults.page.status']
      page.status = Status[default_status] if default_status
      page
    end

    def is_descendant_class_name?(class_name)
      (Page.descendants.map(&:to_s) + [nil, '', 'Page']).include?(class_name)
    end

    def descendant_class(class_name)
      raise ArgumentError.new('argument must be a valid descendant of Page') unless is_descendant_class_name?(class_name)

      if ['', nil, 'Page'].include?(class_name)
        Page
      else
        class_name.constantize
      end
    end

    def missing?
      false
    end

    private

    def default_page_parts(config = TrustyCms::Config)
      default_parts = config['defaults.page.parts'].to_s.strip.split(/\s*,\s*/)
      default_parts.map do |name|
        PagePart.new(name: name, filter_id: config['defaults.page.filter'])
      end
    end

    def default_page_fields(config = TrustyCms::Config)
      default_fields = config['defaults.page.fields'].to_s.strip.split(/\s*,\s*/)
      default_fields.map do |name|
        PageField.new(name: name)
      end
    end
  end

  private

  def valid_class_name
    unless Page.is_descendant_class_name?(class_name)
      errors.add :class_name, 'must be set to a valid descendant of Page'
    end
  end

  def update_virtual
    self.virtual = if self.class == Page.descendant_class(class_name)
                     virtual?
                   else
                     Page.descendant_class(class_name).new.virtual?
                   end
    true
  end

  def clean_path(path)
    "/#{path.to_s.strip}".gsub(%r{//+}, '/')
  end

  alias_method :clean_url, :clean_path

  def parent?
    !parent.nil?
  end

  def database_exists?
    ActiveRecord::Base.connection
  rescue ActiveRecord::NoDatabaseError
    false
  else
    true
  end

  def lazy_initialize_parser_and_context
    unless @parser && @context
      @context = PageContext.new(self)
      @parser = Radius::Parser.new(@context, tag_prefix: 'r')
    end
    @parser
  end

  def parse(text)
    text = '' if text.nil?
    lazy_initialize_parser_and_context.parse(text)
  end

  def parse_object(object)
    text = object.content || ''
    text = parse(text)
    text = object.filter.filter(text) if object.respond_to? :filter_id
    text
  end
end
