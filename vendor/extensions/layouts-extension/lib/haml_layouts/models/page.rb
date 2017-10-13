module HamlLayouts
  module Models
    module Page
      
      def self.included(base)
        base.class_eval do
          
          def parse_object(object)
            # We don't want to return the haml on a layout by default
            text =  object.is_a?(Layout) ? object.rendered_content : object.content
                        
            if object.respond_to? :filter_id
              if object.filter_id == 'Haml'
                # We want to render the tags as html/radius before passing them
                text = object.filter.filter(text)
                text = parse(text)
              else
                text = parse(text)
                text = object.filter.filter(text)
              end
            else
              text = parse(text)
            end
            text
          end
          
        end
      end
      
    end
  end
end

