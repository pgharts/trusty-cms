module MultiSite::SiteControllerExtensions

  # If it's a file not found page and the path doesn't include
  # the site's homepage path, try redirecting to include it.
  module ProcessPageWithHomePath
    def process_page(page)
      homepage = Page.current_site.homepage
      if page.is_a?(FileNotFoundPage) && !params[:url].include?(homepage.slug)
        if homepage.slug != "/"
          false if redirect_to "/#{homepage.slug}/#{params[:url]}"
        else
          super(page)
        end
      else
        super(page)
      end
    end
  end

  def self.included(base)
    base.class_eval do
      before_action :set_site
      prepend ProcessPageWithHomePath
    end
  end

  def set_site
    Page.current_site = Site.find_for_host(request.host)
    true
  end
end
