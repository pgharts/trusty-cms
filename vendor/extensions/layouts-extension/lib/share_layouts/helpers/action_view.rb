module ShareLayouts
  module Helpers
    module ActionView
  
        def self.included(base)
          base.class_eval do
            
            def trusty_layout(name = @trusty_layout)
              page = find_page
              assign_attributes!(page, name)
              page.build_parts_from_hash!(extract_captures)
              page.render
            end
            
            def assign_attributes!(page, name = @trusty_layout)
              page.layout = Layout.where(name: name).first || page.layout
              page.title = @title || @content_for_title || page.title || ''
              page.breadcrumb = @breadcrumb || @content_for_breadcrumb || page.breadcrumb || page.title
              page.breadcrumbs = @breadcrumbs || @content_for_breadcrumbs || nil
              page.url = request.path
              page.slug = page.url.split("/").last
              page.published_at ||= Time.now 
              page.request = request
              page.response = response
            end
            
            def extract_captures
              @view_flow.content.inject({}) do |h, var|
                key = var[0]
                key = :body if key == :layout
                unless key == :title || key == :breadcrumbs
                  h[key] = var[1]
                end
                h
              end
            end
            
            def find_page
              page = Page.find_by_url(request.path) rescue nil
              page.is_a?(RailsPage) ? page : RailsPage.new(:class_name => "RailsPage")
            end
            
          end
        end
      
    end
  end
end