module MultiSite::PagesControllerExtensionsPrepend
  def discover_current_site
    site_from_root || super
  end

  def site_from_root
    if params[:root] && @homepage = Page.find(params[:root])
      @site = @homepage.root.site
    end
  end

  def index
    @site ||= Page.current_site
    @homepage ||= @site.homepage if @site
    @homepage ||= Page.homepage
    response_for :plural
  end

  def remove
    session[:came_from] = request.env["HTTP_REFERER"]
    super
  end

  def continue_url(options = {})
    options[:redirect_to] || (params[:continue] ? edit_admin_page_url(model) : admin_pages_url(:site_id => model.site.id))
  end
end

module MultiSite::PagesControllerExtensions
  def self.included(base)
    base.class_eval do
      prepend MultiSite::PagesControllerExtensionsPrepend

      responses.destroy.default do
        return_url = session[:came_from]
        session[:came_from] = nil
        if model.class == Page or model.class < Page
          redirect_to return_url || admin_pages_url(:site_id => model.site.id)
        else
          redirect_to continue_url(params)
        end
      end
    end
  end
end