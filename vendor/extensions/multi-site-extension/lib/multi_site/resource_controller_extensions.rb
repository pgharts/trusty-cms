module MultiSite::ResourceControllerExtensions

  def self.included(base)
    base.class_eval {
      alias_method :discover_current_site_without_input, :discover_current_site
      alias_method :discover_current_site, :discover_current_site_with_input
    }
  end

  def current_site=(site=nil)
    Page.current_site = site
    set_session_site
  end

  # among other things this determines whether the site chooser is shown in the submenu

  def sited_model?
    model_class == Page || model_class.is_site_scoped?
  end

protected

  def discover_current_site_with_input
    site_from_param || site_from_session || discover_current_site_without_input
  end

  # for interface consistency we want to be able to remember site choices between requests

  def set_session_site(site_id=nil)
    site_id ||= current_site.id.to_s if current_site.is_a? Site
    session[:site_id] = site_id
  end

  def site_from_session
    session[:site_id] && Site.find(session[:site_id]) rescue nil
  end

  def site_from_param
    params[:site_id] && Site.find(params[:site_id]) rescue nil
  end

end
