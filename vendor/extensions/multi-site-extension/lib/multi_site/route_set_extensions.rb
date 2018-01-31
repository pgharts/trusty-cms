module MultiSite
  module RouteSetExtensions

    def self.included(base)
      base.alias_method :extract_request_environment_without_site, :extract_request_environment
      base.alias_method :extract_request_environment, :extract_request_environment_with_site
    end

    def extract_request_environment_with_site(request)
      env = extract_request_environment_without_site(request)
      env.merge! :site => request.host
    end

  end
end

ActionController::Routing::RouteSet.send :include, MultiSite::RouteSetExtensions
