module TrustyCms
  class ExtensionMigrator < ActiveRecord::Migrator
    class << self
      attr_accessor :extension

      def migrate(target_version = nil)
        super extension.migrations_path, target_version
      end

      def migrate_extensions
        []
      end

      def get_all_versions
        ActiveRecord::Base.connection.select_values("SELECT version FROM #{sanitize(schema_migrations_table_name)}").
          select { |version| version.starts_with?("#{@extension.extension_name}-") }.
          map { |version| version.sub("#{@extension.extension_name}-", '').to_i }.sort
      end
    end

    def initialize(direction, migrations_path, target_version = nil)
      super
      initialize_extension_schema_migrations
      initialize_received_migrations
    end

    private

    def quote(s)
      ActiveRecord::Base.connection.quote(s)
    end

    def extension_name
      self.class.extension.extension_name
    end

    def version_string(version)
      "#{extension_name}-#{version}"
    end

    def initialize_extension_schema_migrations
      current_version = ActiveRecord::Base.connection.select_value("SELECT schema_version FROM extension_meta WHERE name = #{sanitize(quote(extension_name))}")
      if current_version
        assume_migrated_upto_version(current_version.to_i)
        ActiveRecord::Base.connection.delete("DELETE FROM extension_meta WHERE name = #{sanitize(quote(extension_name))}")
      end
    end

    def initialize_received_migrations
      if donors = self.class.extension.migrates_from
        donors.each do |extension_name, until_migration|
          replaced = ActiveRecord::Base.connection.select_values("SELECT version FROM #{sanitize(ActiveRecord::Migrator.schema_migrations_table_name)} WHERE version LIKE '#{extension_name}-%'").map { |v| v.sub(/^#{extension_name}\-/, '').to_i }
          replaced.delete_if { |v| v > until_migration.to_i } if until_migration
          assume_migrated_upto_version(replaced.max) if replaced.any?
        end
      end
    end

    def assume_migrated_upto_version(version)
      version = version.to_i
      sm_table = self.class.schema_migrations_table_name

      migrated = self.class.get_all_versions
      versions = Dir["#{@migrations_path}/[0-9]*_*.rb"].map do |filename|
        filename.split('/').last.split('_').first.to_i
      end

      unless migrated.include?(version)
        ActiveRecord::Base.connection.execute "INSERT INTO #{sm_table} (version) VALUES (#{sanitize(quote(version_string(version)))})"
      end

      inserted = Set.new
      (versions - migrated).each do |v|
        if inserted.include?(v)
          raise "Duplicate migration #{v}. Please renumber your migrations to resolve the conflict."
        elsif v < version
          ActiveRecord::Base.connection.execute "INSERT INTO #{sm_table} (version) VALUES (#{sanitize(quote(version_string(v)))})"
          inserted << v
        end
      end
    end
  end
end
