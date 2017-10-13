module ShareLayouts
  module Controllers
    module ActionController

      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def trusty_layout(name=nil, options={}, &block)
          raise ArgumentError, "A layout name or block is required!" unless name || block
          class_attribute :trusty_layout
          self.trusty_layout = name || block
          before_action :set_trusty_layout
          layout 'trusty', options
        end
      end

      def set_trusty_layout
        @trusty_layout = self.class.trusty_layout
        @trusty_layout = @trusty_layout.call(self) if @trusty_layout.is_a? Proc
      end

    end
  end
end
