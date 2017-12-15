class Admin::PagesController < Admin::ResourceController
  before_action :initialize_meta_rows_and_buttons, :only => [:new, :edit, :create, :update]
  before_action :count_deleted_pages, :only => [:destroy]
  rescue_from ActiveRecord::RecordInvalid, :with => :validation_error

  class PreviewStop < ActiveRecord::Rollback
    def message
      'Changes not saved!'
    end
  end

  create_responses do |r|
    r.plural.js do
      @level = params[:level].to_i
      @index = params[:index].to_i
      @rendered_html = ""
      @template_name = 'index'
      self.models = Page.find(params[:page_id]).children.all
      response.headers['Content-Type'] = 'text/html;charset=utf-8'
      render :action => 'children.html.haml', :layout => false
    end
  end

  def index
    @homepage = Page.find_by_parent_id(nil)
    response_for :plural
  end

  def new
    @page = self.model = model_class.new_with_defaults(trusty_config)
    assign_page_attributes
    response_for :new
  end

  def preview
    render_preview
  rescue PreviewStop => exception
    render :text => exception.message unless @performed_render
  end

  def save_table_position
    new_position = params[:new_position]
    Page.save_order(new_position)
    head :ok
  end


  private

    def validation_error(e)
      flash[:error] = e.message
      render :new
    end

    def assign_page_attributes
      if params[:page_id].blank?
        self.model.slug = '/'
      end
      self.model.parent_id = params[:page_id]
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
        page_class = Page.descendants.include?(model_class) ? model_class : Page
        if request.referer =~ %r{/admin/pages/(\d+)/edit}
          page = Page.find($1).becomes(page_class)
          layout_id = page.layout_id
          page.update_attributes(params[:page])
          page.published_at ||= Time.now
        else
          page = page_class.new(params[:page])
          page.published_at = page.updated_at = page.created_at = Time.now
          page.parent = Page.find($1) if request.referer =~ %r{/admin/pages/(\d+)/children/new}
        end
        page.pagination_parameters = pagination_parameters
        process_with_exception(page)
      end
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
      @meta << {:field => "slug", :type => "text_field", :args => [{:class => 'textbox', :maxlength => 100}]}
      @meta << {:field => "breadcrumb", :type => "text_field", :args => [{:class => 'textbox', :maxlength => 160}]}
    end

  def verify_page_class(page_class)
    if page_class.constantize.ancestors.include?(Page)
      page_class.constantize
    else
      raise "I'm not allowed to constantize #{page_class}!"
    end
  end
end
