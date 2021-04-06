require 'rails_generator/base'
require 'rails_generator/generators/components/model/model_generator'

class ExtensionModelGenerator < ModelGenerator

  attr_accessor :extension_name
  default_options :with_test_unit => false

  def initialize(runtime_args, runtime_options = {})
    runtime_args = runtime_args.dup
    @extension_name = runtime_args.shift
    super(runtime_args, runtime_options)
  end

  def manifest
    if extension_uses_rspec?
      rspec_manifest
    else
      super
    end
  end

  def rspec_manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions class_path, class_name

      # Model, spec, and fixture directories.
      m.directory File.join('app/models', class_path)
      m.directory File.join('spec/models', class_path)
      # m.directory File.join('spec/fixtures', class_path)

      # Model class, spec and fixtures.
      m.template 'model:model.rb',      File.join('app/models', class_path, "#{file_name}.rb")
      # m.template 'model:fixtures.yml',  File.join('spec/fixtures', class_path, "#{table_name}.yml")
      m.template 'model_spec.rb',       File.join('spec/models', class_path, "#{file_name}_spec.rb")

      unless options[:skip_migration]
        m.migration_template 'model:migration.rb', 'db/migrate', :assigns => {
          :migration_name => "Create#{class_name.pluralize.gsub(/::/, '')}"
        }, :migration_file_name => "create_#{file_path.gsub(/\//, '_').pluralize}"
      end
    end
  end

  def banner
    "Usage: #{$0} extension_model ExtensionName ModelName [field:type, field:type]"
  end

  def extension_path
    File.join('vendor', 'extensions', @extension_name.underscore)
  end

  def destination_root
    File.join(Rails.root, extension_path)
  end

  def extension_uses_rspec?
    File.exists?(File.join(destination_root, 'spec')) && !options[:with_test_unit]
  end

  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on("--with-test-unit",
           "Use Test::Unit tests instead sof RSpec.") { |v| options[:with_test_unit] = v }
  end
end
