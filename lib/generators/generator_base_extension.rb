require 'rails_generator'
module TrustyCms
  module GeneratorBaseExtension
    def self.included(base)
      base.class_eval {
        alias_method :existing_migrations_without_extensions, :existing_migrations
        alias_method :existing_migrations, :existing_migrations_with_extensions
      }
    end

    def existing_migrations_with_extensions(file_name)
      Dir.glob("#{destination_path(@migration_directory)}/[0-9]*_*.rb").grep(/[0-9]+_#{file_name}.rb$/)
    end

  end
end

Rails::Generator::Commands::Base.class_eval { include TrustyCms::GeneratorBaseExtension }
