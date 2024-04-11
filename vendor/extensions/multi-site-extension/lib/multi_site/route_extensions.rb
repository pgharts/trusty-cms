module MultiSite
  module RouteExtensions
    module RecognitionConditionsWithSite
      def recognition_conditions
        result = super
        if site_names = conditions.delete(:site)
          domains = [*site_names].map { |site| Regexp.compile(::Site.find_by_name(site).domain) }
          conditions[:site] = Regexp.union(*domains)
          result << "conditions[:site] === env[:site]"
        end
        result
      end
    end

    def self.included(base)
      base.prepend RecognitionConditionsWithSite
    end
  end
end

ActionController::Routing::Route.include MultiSite::RouteExtensions