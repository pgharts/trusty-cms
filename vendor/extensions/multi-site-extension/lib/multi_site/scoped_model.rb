module MultiSite

  module ScopedModel
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def is_site_scoped?
        false
      end

      # only option at the moment is :shareable, which we take to mean that sites are optional:
      # if true it causes us not to set the site automatically or to validate its presence,
      # and to extend the scoping conditions so that objects with no site are returned as
      # well as objects with the specified site
      # that is, anything without a site is considered to be shared among all sites
      # the default is false

      def is_site_scoped(options={})
        return if is_site_scoped?

        options = {
          :shareable => false
        }.merge(options)

        class_eval <<-EO
          default_scope {where(site_scope_condition)}
          extend MultiSite::ScopedModel::ScopedClassMethods
          include MultiSite::ScopedModel::ScopedInstanceMethods
        EO

        belongs_to :site
        Site.send(:has_many, plural_symbol_for_class)

        before_validation :set_site
        validates_presence_of :site unless options[:shareable]

        class << self
          attr_accessor :shareable
          alias_method :paginate_without_site, :paginate
          alias_method :paginate, :paginate_with_site
          %w{count average minimum maximum sum}.each do |getter|
            alias_method "#{getter}_without_site".intern, getter.intern
            alias_method getter.intern, "#{getter}_with_site".intern
          end
        end

        self.shareable = options[:shareable]
      end
    end

    module ScopedClassMethods


      def paginate_with_site(options={})
        return paginate_without_site(options) unless sites?
        where(site_scope_condition) do
          paginate_without_site(options)
        end
      end

      %w{count average minimum maximum sum}.each do |getter|
        define_method("#{getter}_with_site") do |*args|
          return send("#{getter}_without_site".intern, *args) unless sites?
          with_scope(:find => {:conditions => site_scope_condition}) do
            send "#{getter}_without_site".intern, *args
          end
        end
      end

      # this only works with :all and :first
      # and should only be used in odd cases like migration.
      def find_without_site(*args)
        options = args.extract_options!
        #set_readonly_option!(options)

        case args.first
          when :first then find_initial_without_site(options)     # defined here
          when :all   then all_without_site(options)       # already defined by the alias chain
        end
      end

      def find_initial_without_site(options)
        options.update(:limit => 1)
        all_without_site(options).first
      end

      def sites?
        Site.table_exists? && Site.several?
      end

      def current_site!
        raise(ActiveRecord::SiteNotFound, "#{self} is site-scoped but current_site is #{self.current_site.inspect}", caller) if sites? && !self.current_site && !self.is_shareable?
        self.current_site
      end

      def current_site
        Page.current_site
      end

      def site_scope_condition
        if self.shareable
          condition = ""
          condition << "#{self.table_name}.site_id = #{self.current_site.id} OR " if self.current_site
          condition << "#{self.table_name}.site_id IS NULL"
        else
          condition = "#{self.table_name}.site_id = #{self.current_site!.id}"
        end
        condition
      end

      def plural_symbol_for_class
        self.to_s.pluralize.underscore.intern
      end

      def is_site_scoped?
        true
      end

      def is_shareable?
        !!self.shareable
      end
    end

    module ScopedInstanceMethods
      protected
        def set_site
          self.site ||= self.class.current_site! unless self.class.is_shareable?
        end
    end
  end
end
