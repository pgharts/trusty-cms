namespace :trusty_cms do
  namespace :extensions do
    namespace :layouts do
      
      desc "Runs the migration of the Layouts extension"
      task :migrate => :environment do
        require 'trusty/extension_migrator'
        if ENV["VERSION"]
          LayoutsExtension.migrator.migrate(ENV["VERSION"].to_i)
          Rake::Task['db:schema:dump'].invoke
        else
          LayoutsExtension.migrator.migrate
          Rake::Task['db:schema:dump'].invoke
        end
      end
      
      desc "Copies public assets of the Layouts to the instance public/ directory."
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        puts "Copying assets from LayoutsExtension"
        Dir[LayoutsExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(LayoutsExtension.root, '')
          directory = File.dirname(path)
          mkdir_p Rails.root.to_s + directory, :verbose => false
          cp file, Rails.root.to_s + path, :verbose => false
        end
        unless LayoutsExtension.root.starts_with? Rails.root.to_s # don't need to copy vendored tasks
          puts "Copying rake tasks from LayoutsExtension"
          local_tasks_path = File.join(Rails.root.to_s, %w(lib tasks))
          mkdir_p local_tasks_path, :verbose => false
          Dir[File.join LayoutsExtension.root, %w(lib tasks *.rake)].each do |file|
            cp file, local_tasks_path, :verbose => false
          end
        end
      end  
      
      desc "Syncs all available translations for this ext to the English ext master"
      task :sync => :environment do
        # The main translation root, basically where English is kept
        language_root = LayoutsExtension.root + "/config/locales"
        words = TranslationSupport.get_translation_keys(language_root)
        
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
  end
end
