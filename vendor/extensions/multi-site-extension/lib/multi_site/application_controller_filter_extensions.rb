module MultiSite::ApplicationControllerFilterExtensions
  protected

  def authenticate
    self.current_site = discover_current_site
    super
  end

  def set_site
    true if (self.current_site = discover_current_site)
  end
end

class ApplicationController < ActionController::Base
  prepend MultiSite::ApplicationControllerFilterExtensions
  prepend_before_action :set_site
end