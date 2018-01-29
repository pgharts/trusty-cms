module MultiSite::ApplicationControllerFilterExtensions

  def self.included(base)
    base.class_eval {
      prepend_before_action :set_site
      alias_method :authenticate_without_site, :authenticate
      alias_method :authenticate, :authenticate_with_site
    }
  end

protected

  def authenticate_with_site
    self.current_site = discover_current_site
    authenticate_without_site
  end

  def set_site
    true if self.current_site = discover_current_site
  end

end
