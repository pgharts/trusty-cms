namespace :trusty do
  namespace :extensions do
    namespace :clipped do
      
      desc "Runs the migration of the Clipped extension"
      task :migrate => :environment do
        require 'trusty/extension_migrator'
        if ActiveRecord::Base.connection.select_values("SELECT version FROM #{ActiveRecord::Migrator.schema_migrations_table_name} WHERE version = 'Assets-20110513205050'").any?
          puts "Assimilating Assets extension migration 20110513205050"
          ClippedExtension.migrator.new(:up, ClippedExtension.migrations_path).send(:assume_migrated_upto_version, '20110513205050')
        end
        
        if ENV["VERSION"]
          ClippedExtension.migrator.migrate(ENV["VERSION"].to_i)
          Rake::Task['db:schema:dump'].invoke
        else
          ClippedExtension.migrator.migrate
          Rake::Task['db:schema:dump'].invoke
        end
      end
      
      desc "Copies public assets of the Clipped extension to the instance public/ directory."
      task :update => [:environment, :initialize] do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        puts "Copying assets from ClippedExtension"
        Dir[ClippedExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(ClippedExtension.root, '')
          directory = File.dirname(path)
          mkdir_p Rails.root + directory, :verbose => false
          cp_r file, Rails.root + path, :verbose => false
        end

        desc "Syncs all available translations for this ext to the English ext master"
        task :sync => :environment do
          # The main translation root, basically where English is kept
          language_root = ClippedExtension.get_translation_keys(language_root)

          Dir["#{language_root}/*.yml"].each do |filename|
            next if filename.match('_available_tags')
            basename = File.basename(filename, '.yml')
            puts "Syncing #{basename}"
            (comments, other) = TranslationSupport.read_file(filename, basename)
            words.each { |k,v| other[k] ||= words[k] }  # Initializing hash variable as empty if it does not exist
            other.delete_if { |k,v| !words[k] }         # Remove if not defined in en.yml
            TranslationSupport.write_file(filename, basename, comments, other)
          end
        end
      end
      
      desc "Exports assets from database to assets directory"
      task :export => :environment do
        asset_path = File.join(Rails.root, "assets")
        mkdir_p asset_path
        Asset.find(:all).each do |asset|
          puts "Exporting #{asset.asset_file_name}"
          cp asset.asset.path, File.join(asset_path, asset.asset_file_name)
        end
        puts "Done."
      end

      desc "Imports assets to database from assets directory"
      task :import => :environment do
        asset_path = File.join(Rails.root, "assets")
        if File.exist?(asset_path) && File.stat(asset_path).directory?
          Dir.glob("#{asset_path}/*").each do |file_with_path|
            if File.stat(file_with_path).file?
              new_asset = File.new(file_with_path) 
              puts "Creating #{File.basename(file_with_path)}"
              Asset.create :asset => new_asset
            end
          end
        end
      end
    end
  end
end
