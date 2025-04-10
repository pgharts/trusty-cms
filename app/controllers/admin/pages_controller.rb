class Admin::PagesController < Admin::ResourceController
  before_action :initialize_meta_rows_and_buttons, only: %i[new edit create update]
  before_action :count_deleted_pages, only: [:destroy]
  before_action :set_page, only: %i[edit restore]
  rescue_from ActiveRecord::RecordInvalid, with: :validation_error
  include Admin::PagesHelper
  include Admin::UrlHelper

  class PreviewStop < ActiveRecord::Rollback
    def message
      'Changes not saved!'
    end
  end

  create_responses do |r|
    r.plural.js do
      @level = params[:level].to_i
      @index = params[:index].to_i
      @rendered_html = ''
      @template_name = 'index'
      self.models = Page.find(params[:page_id]).children.all
      response.headers['Content-Type'] = 'text/html;charset=utf-8'
      render action: 'children', layout: false
    end
  end

  def index
    set_site_and_homepage
    @q = initialize_search
    response_for :plural
  end

  def search
    @site_id = params[:site_id] || Page.current_site.id
    @q = initialize_search

    @pages = fetch_search_results if search_query_present?
    render
  end

  def new
    assets = Asset.order('created_at DESC')
    @term = assets.ransack(params[:search] || '')
    @page = self.model = model_class.new_with_defaults(trusty_config)
    @render_preview_button = render_preview_button?
    assign_page_attributes
    response_for :new
  end

  def edit
    verify_site_id
    load_assets
    @page_url = generate_page_url(request.url, @page)
    @page_path = format_path(@page.path)
    @versions = format_versions(@page.versions)
    @render_preview_button = render_preview_button?
    response_for :edit
  end

  def restore
    index = params[:version_index].to_i
    restore_page_version(@page, index)
    redirect_to edit_admin_page_path(@page)
  end

  def preview
    render_preview
  rescue PreviewStop => e
    render text: e.message unless @performed_render
  end

  def save_table_position
    new_position = params[:new_position]
    Page.save_order(new_position)
    head :ok
  end

  private

  def set_page
    @page = Page.find(params[:id])
  end

  def set_site_and_homepage
    @site ||= Page.current_site
    @homepage = @site&.homepage || Page.homepage
    @site_id = @site&.id
  end

  def verify_site_id
    page_site_id = @page.site_id
    user_site_ids = current_user.admins_sites.each.pluck(:site_id)
    unless user_site_ids.include?(page_site_id)
      redirect_to admin_pages_url
    end
  end

  def load_assets
    assets = Asset.order(created_at: :desc)
    @term = assets.ransack(params[:search].presence || {})
    @term.result(distinct: true)
  end

  def initialize_search
    Page.ransack(params[:search] || '')
  end

  def fetch_search_results
    @query = params.dig(:search, :query)
    Page.ransack(title_cont: @query, site_id_eq: @site_id).result
      .or(Page.ransack(slug_cont: @query, site_id_eq: @site_id).result)
  end

  def search_query_present?
    params.dig(:search, :query).present?
  end

  def validation_error(e)
    flash[:error] = e.message
    render :new
  end

  def assign_page_attributes
    if params[:page_id].blank?
      model.slug = '/'
    end
    model.parent_id = params[:page_id]
  end

  def format_versions(versions)
    return nil unless versions.any?

    versions
      .sort_by(&:created_at).reverse
      .map do |version|
      {
        index: version&.index,
        update_date: version&.created_at&.strftime('%B %d, %Y'),
        update_time: version&.created_at&.strftime('%I:%M %p'),
        updated_by: User.unscoped.find_by(id: version&.whodunnit)&.name || 'Unknown User',
      }
    end
  end

  def restore_page_version(page, index)
    lock_version = page.lock_version
    restored_page = page.versions[index].reify(has_many: true)
    restored_page.lock_version = lock_version
    restored_page.save!
  end

  def model_class
    if Page.descendants.any? { |d| d.to_s == params[:page_class] }
      verify_page_class(params[:page_class])
    elsif params[:page_id]
      Page.find(params[:page_id]).children
    else
      Page
    end
  end

  def render_preview
    params.permit!
    Page.transaction do
      page = build_preview_page
      page.pagination_parameters = pagination_parameters
      process_with_exception(page)
    end
  end

  def build_preview_page
    page_class = Page.descendants.include?(model_class) ? model_class : Page
    referer_page_id = extract_page_id_from_referer

    if editing_existing_page?
      page = Page.find(referer_page_id).becomes(page_class)
      page.update(params[:page])
      page.published_at ||= Time.current
    else
      page = page_class.new(params[:page])
      now = Time.current
      page.published_at = page.updated_at = page.created_at = now

      if creating_child_page?
        parent = Page.find(referer_page_id)
        page.parent = parent
        page.layout_id ||= parent.layout_id
      end

      page.save!
    end

    page
  end

  def editing_existing_page?
    request.referer =~ %r{/admin/pages/\d+/edit}
  end

  def creating_child_page?
    request.referer =~ %r{/admin/pages/\d+/children/new}
  end

  def extract_page_id_from_referer
    request.referer[%r{/admin/pages/(\d+)}, 1]
  end  

  def process_with_exception(page)
    page.process(request, response)
    @performed_render = true
    render template: 'site/show_page', layout: false
    raise PreviewStop
  end

  def count_deleted_pages
    @count = model.children.count + 1
  end

  def initialize_meta_rows_and_buttons
    @buttons_partials ||= []
    @meta ||= []
    @meta << { field: 'slug', type: 'text_field', args: [{ class: 'textbox' }] }
    @meta << { field: 'breadcrumb', type: 'text_field', args: [{ class: 'textbox' }] }
  end

  def verify_page_class(page_class)
    if page_class.constantize.ancestors.include?(Page)
      page_class.constantize
    else
      raise "I'm not allowed to constantize #{page_class}!"
    end
  end

  def render_preview_button?
    page_class = @page.class.name
    previewable_classes = ['Page']
    previewable_classes += PREVIEW_PAGE_TYPES if defined?(PREVIEW_PAGE_TYPES)
    previewable_classes.include?(page_class)
  end
end
