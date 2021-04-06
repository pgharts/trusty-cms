module TrustyCms::Taggable
  mattr_accessor :last_description, :tag_descriptions, :tag_deprecations
  @@tag_descriptions = {}
  @@tag_deprecations = {}

  def self.included(base)
    base.extend(ClassMethods)
    base.module_eval do
      def self.included(new_base)
        super
        new_base.class_eval do
          include Rails.application.routes.url_helpers
        end
        class << new_base
          def default_url_options
            { controller: 'site', action: 'show_page', only_path: true }
          end
        end
        new_base.tag_descriptions.merge! tag_descriptions
      end

      protected

      def params
        @params ||= request.parameters unless request.nil?
      end

      def request_uri
        @request_url ||= request.request_uri unless request.nil?
      end
    end
  end

  def render_tag(name, tag_binding)
    tag_method_name = "tag:#{name}"
    tag_method = method(tag_method_name)
    if tag_method.arity == 0
      tag_method.call
    else
      tag_method.call tag_binding
    end
  end

  def tags
    Util.tags_in_array(methods)
  end

  def tag_descriptions(hash = nil)
    self.class.tag_descriptions hash
  end

  def warn_of_tag_deprecation(tag_name, options = {})
    message = "Deprecated radius tag <r:#{tag_name}>"
    message << " will be removed or significantly changed in trusty #{options[:deadline]}." if options[:deadline]
    message << " Please use <r:#{options[:substitute]}> instead." if options[:substitute]
    ActiveSupport::Deprecation.warn(message)
  end

  module ClassMethods
    def inherited(subclass)
      subclass.tag_descriptions.reverse_merge! tag_descriptions
      super
    end

    def tag_descriptions(hash = nil)
      TrustyCms::Taggable.tag_descriptions[name] ||= (hash || {})
    end

    def desc(text)
      TrustyCms::Taggable.last_description = text
      # TrustyCms::Taggable.last_description = RedCloth.new(Util.strip_leading_whitespace(text)).to_html
    end

    def tag(name, &block)
      tag_descriptions[name] = TrustyCms::Taggable.last_description if TrustyCms::Taggable.last_description
      TrustyCms::Taggable.last_description = nil
      define_method("tag:#{name}", &block)
    end

    def tags
      Util.tags_in_array(instance_methods)
    end

    # Define a tag while also deprecating it. Normal usage:
    #
    #   deprecated_tag 'old:way', :substitute => 'new:way', :deadline => '1.1.1'
    #
    # If no substitute is given then a warning will be issued but nothing rendered.
    # If a deadline version is provided then it will be mentioned in the deprecation warnings.
    #
    # In less standard situations you can use deprecated_tag in exactly the
    # same way as tags are normally defined:
    #
    # desc %{
    #   Please note that the old r:busted namespace is no longer supported.
    #   Refer to the documentation for more about the new r:hotness tags.
    # }
    # deprecated_tag 'busted' do |tag|
    #   raise TagError "..."
    # end
    #
    def deprecated_tag(name, options = {}, &dblock)
      TrustyCms::Taggable.tag_deprecations[name] = options.dup
      if dblock
        tag(name) do |tag|
          warn_of_tag_deprecation(name, options)
          dblock.call(tag)
        end
      else
        tag(name) do |tag|
          warn_of_tag_deprecation(name, options)
          tag.render(options[:substitute], tag.attr.dup, &tag.block) if options[:substitute]
        end
      end
    end
  end

  module Util
    def self.tags_in_array(array)
      array.grep(/^tag:/).map { |name| name[4..-1] }.sort
    end

    def self.strip_leading_whitespace(text)
      text = text.dup
      text.gsub!("\t", '  ')
      lines = text.split("\n")
      leading = lines.map do |line|
        unless line =~ /^\s*$/
          line.match(/^(\s*)/)[0].length
        end
      end.compact.min
      lines.inject([]) { |ary, line| ary << line.sub(/^[ ]{#{leading}}/, '') }.join("\n")
    end
  end
end
