module MultiSite::PagesControllerExtensions
  def self.included(base)
    base.class_eval {
      alias_method :discover_current_site_without_root, :discover_current_site
      alias_method :discover_current_site, :discover_current_site_with_root

      alias_method :index_without_site, :index

      alias_method :remove_without_back, :remove
      alias_method :remove, :remove_with_back
      responses.destroy.default do
        session[:came_from] = nil
        redirect_to admin_pages_url(site_id: model.site.id)
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

  def remove_with_back
    session[:came_from] = request.env["HTTP_REFERER"]
    remove_without_back
  end
end
