module TrustyCms
  module Pagination
    module Controller
      # for inclusion into public-facing controllers

      def configure_pagination
        # unconfigured parameters remain at will_paginate defaults
        # will_paginate controller options are not overridden by tag attribetus
        WillPaginate::ViewHelpers.pagination_options[:param_name] = TrustyCms::Config["pagination.param_name"].to_sym unless TrustyCms::Config["pagination.param_name"].blank?
        WillPaginate::ViewHelpers.pagination_options[:per_page_param_name] = TrustyCms::Config["pagination.per_page_param_name"].blank? ? :per_page : TrustyCms::Config["pagination.per_page_param_name"].to_sym

        # will_paginate view options can be overridden by tag attributes
        [:class, :previous_label, :next_label, :inner_window, :outer_window, :separator, :container].each do |opt|
          WillPaginate::ViewHelpers.pagination_options[opt] = TrustyCms::Config["pagination.#{opt}"] unless TrustyCms::Config["pagination.#{opt}"].blank?
        end
      end

      def pagination_parameters
        {
          :page => params[WillPaginate::ViewHelpers.pagination_options[:param_name]] || 1,
          :per_page => params[WillPaginate::ViewHelpers.pagination_options[:per_page_param_name]] || TrustyCms::Config['pagination.per_page'] || 20
        }
      end

      def self.included(base)
        base.class_eval {
          helper_method :pagination_parameters
          before_action :configure_pagination
        }
      end
    end
  end



end





