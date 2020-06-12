module InheritableClassAttributes
  def self.included(base)
    base.extend ClassMethods
    base.module_eval do
      class << self
        alias inherited_without_inheritable_class_attributes inherited
        alias inherited inherited_with_inheritable_class_attributes
      end
    end
  end

  module ClassMethods
    def inheritable_cattr_readers
      @inheritable_class_readers ||= []
    end

    def inheritable_cattr_writers
      @inheritable_class_writers ||= []
    end

    def cattr_inheritable_reader(*symbols)
      symbols.each do |symbol|
        inheritable_cattr_readers << symbol
        module_eval %{
          def self.#{symbol}
            @#{symbol}
          end
        }
      end
      inheritable_cattr_readers.uniq!
    end

    def cattr_inheritable_writer(*symbols)
      symbols.each do |symbol|
        inheritable_cattr_writers << symbol
        module_eval %{
          def self.#{symbol}=(value)
            @#{symbol} = value
          end
        }
      end
      inheritable_cattr_writers.uniq!
    end

    def cattr_inheritable_accessor(*symbols)
      cattr_inheritable_writer(*symbols)
      cattr_inheritable_reader(*symbols)
    end

    def inherited_with_inheritable_class_attributes(klass)
      inherited_without_inheritable_class_attributes(klass) if respond_to?(:inherited_without_inheritable_class_attributes)

      readers = inheritable_cattr_readers.dup
      writers = inheritable_cattr_writers.dup
      inheritables = %i[inheritable_cattr_readers inheritable_cattr_writers]

      (readers + writers + inheritables).uniq.each do |attr|
        var = "@#{attr}"
        old_value = module_eval(var)
        new_value = (begin
                       old_value.dup
                     rescue StandardError
                       old_value
                     end)
        klass.module_eval("#{var} = new_value")
      end
    end
  end
end
