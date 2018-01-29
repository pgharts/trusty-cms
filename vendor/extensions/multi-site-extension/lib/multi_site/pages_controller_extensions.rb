module MultiSite::PagesControllerExtensions
  def self.included(base)
    base.class_eval {
      alias_method :discover_current_site_without_root, :discover_current_site
      alias_method :discover_current_site, :discover_current_site_with_root

      alias_method :index_without_site, :index
      alias_method :index, :index_with_site

      alias_method :continue_url_without_site, :continue_url
      alias_method :continue_url, :continue_url_with_site

      alias_method :remove_without_back, :remove
      alias_method :remove, :remove_with_back
      responses.destroy.default do
        return_url = session[:came_from]
        session[:came_from] = nil
        if model.class == Page or model.class < Page
          redirect_to return_url || admin_pages_url(:site_id => model.site.id)
        else
          redirect_to continue_url(params)
        end
      end
    }
  end

  # for compatibility with the standard issue of multi_site,
  # a root parameter overrides other ways of setting site

  def discover_current_site_with_root
    site_from_root || discover_current_site_without_root
  end

  def site_from_root
    if params[:root] && @homepage = Page.find(params[:root])
      @site = @homepage.root.site
    end
  end

  def index_with_site
    @site ||= Page.current_site
    @homepage ||= @site.homepage if @site
    @homepage ||= Page.homepage
    response_for :plural
  end

  def remove_with_back
    session[:came_from] = request.env["HTTP_REFERER"]
    remove_without_back
  end

  def continue_url_with_site(options={})
    options[:redirect_to] || (params[:continue] ? edit_admin_page_url(model) : admin_pages_url(:site_id => model.site.id))
  end
end
