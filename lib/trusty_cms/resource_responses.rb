require 'ostruct'
module TrustyCms
  module ResourceResponses
    def self.extended(base)
      base.send :class_attribute, :responses
      base.send :include, InstanceMethods
    end

    def create_responses
      r = (self.responses ||= Collector.new)
      yield r if block_given?
      r
    end

    module InstanceMethods
      def response_for(action)
        responses = self.class.responses.send(action)
        respond_to do |wants|
          responses.each_format do |f, format_block|
            if format_block
              wants.send(f, &wrap(format_block))
            else
              wants.send(f)
            end
          end
          responses.each_published do |pub, pub_block|
            wants.send(pub, &wrap(pub_block))
          end
          if responses.default
            wants.any(&wrap(responses.default))
          else
            wants.any
          end
        end
      end

      def wrap(proc)
        # Makes sure our response blocks get evaluated in the right context
        lambda do
          # Ruby 1.9.2 yields self in instance_eval... see https://gist.github.com/479572
          # lambdas are as strict as methods in 1.9.x, making sure that the args match, Procs are not.
          if RUBY_VERSION =~ /^1\.9/ && proc.lambda? && (proc.arity != 1)
            raise "You can only pass a proc ('Proc.new') or a lambda that takes exactly one arg (for self) to the wrap method."
          end

          instance_eval(&proc)
        end
      end
    end

    class Collector < OpenStruct
      def initialize
        super
        @table = Hash.new { |h, k| h[k] = Response.new }
      end

      def initialize_copy(orig)
        super
        @table.keys.each do |key|
          @table[key] = orig.send(key).dup
        end
      end
    end

    class Response
      attr_reader :publish_formats, :publish_block, :blocks, :block_order
      def initialize
        @publish_formats = []
        @blocks = {}
        @block_order = []
      end

      def initialize_copy(orig)
        @publish_formats = orig.publish_formats.dup
        @blocks = orig.blocks.dup
        @block_order = orig.block_order.dup
        @publish_block = orig.publish_block.dup if orig.publish_block
        @default = orig.default.dup if orig.default
      end

      def default(&block)
        if block_given?
          @default = block
        end
        @default
      end

      def publish(*formats, &block)
        @publish_formats.concat(formats)
        if block_given?
          @publish_block = block
        else
          raise ArgumentError, 'Block required to publish' unless @publish_block
        end
      end

      def each_published
        publish_formats.each do |format|
          yield format, publish_block if block_given?
        end
      end

      def each_format
        @block_order.each do |format|
          yield format, @blocks[format] if block_given?
        end
      end

      def method_missing(method, *args, &block)
        if block_given?
          @blocks[method] = block
          @block_order << method unless @block_order.include?(method)
        elsif args.empty?
          @block_order << method
        else
          super
        end
      end
    end
  end
end
