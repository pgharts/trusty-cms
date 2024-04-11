module MultiSite
  module RouteSetExtensions
    module ExtractRequestEnvironmentWithSite
      def extract_request_environment(request)
        env = super(request)
        env.merge! :site => request.host
      end
    end

    def self.included(base)
      base.prepend ExtractRequestEnvironmentWithSite
    end
  end
end

ActionController::Routing::RouteSet.include MultiSite::RouteSetExtensions