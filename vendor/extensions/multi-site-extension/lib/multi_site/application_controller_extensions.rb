module MultiSite::ApplicationControllerExtensions

  def current_site
    Page.current_site
  end

  def current_site=(site=nil)
    Page.current_site = site
  end

  # this is overridden in Admin::ResourceController to respond correctly
  
  def sited_model?
    false
  end


  def set_site
    true if self.current_site = discover_current_site
  end

  # chains will attach here

  def discover_current_site
    site_from_host
  end

  # and add more ways to determine the current site

  def site_from_host
    Site.find_for_host(request.host)
  end

  def self.included(base)
    base.class_eval {
      helper_method :current_site, :current_site=
    }
  end

end
