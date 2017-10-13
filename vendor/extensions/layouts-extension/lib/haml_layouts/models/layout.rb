module HamlLayouts
  module Models
    module Layout
      
      def self.included(base)
        base.class_eval do
          
          # Will render html from haml if necessary
          def rendered_content
            if is_haml?
              # The gsub will replace all escaped radius tags with html
              HamlFilter.filter(content)
            else
              content
            end
          end
          
          # Returns 'text/html' to the browser (if haml)           
          def content_type
            self[:content_type] == 'haml' ? 'text/html' : self[:content_type]
          end

          # Overwrites the standard Trusty CMS Render and pumps out haml if necessary
          def is_haml?
            self[:content_type] == 'haml'
          end
          
        end
      end
      
    end
  end
end