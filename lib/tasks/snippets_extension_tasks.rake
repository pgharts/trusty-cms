namespace :trusty do
  namespace :extensions do
    namespace :snippets do
      
      desc 'Runs the migration of the Snippets extension'
      task :migrate => :environment do
        require 'trusty_cms/extension_migrator'
        if ENV['VERSION']
          SnippetsExtension.migrator.migrate(ENV['VERSION'].to_i)
          Rake::Task['db:schema:dump'].invoke
        else
          SnippetsExtension.migrator.migrate
          Rake::Task['db:schema:dump'].invoke
        end
      end

      desc 'Copies public assets of the Snippets to the instance public/ directory.'
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        puts 'Copying assets from SnippetsExtension'
        Dir[SnippetsExtension.root + '/public/**/*'].reject(&is_svn_or_dir).each do |file|
          path = file.sub(SnippetsExtension.root, '')
          directory = File.dirname(path)
          mkdir_p Rails.root + directory, :verbose => false
          cp file, Rails.root + path, :verbose => false
        end
      end
      
      desc 'Syncs all available translations for this ext to the English ext master'
      task :sync => :environment do
        # The main translation root, basically where English is kept
        language_root = SnippetsExtension.root + '/config/locales'
        words = TranslationSupport.get_translation_keys(language_root)
        
        Dir['#{language_root}/*.yml'].each do |filename|
          next if filename.match('_available_tags')
          basename = File.basename(filename, '.yml')
          puts "Syncing #{basename}"
          (comments, other) = TranslationSupport.read_file(filename, basename)
          words.each { |k, v| other[k] ||= words[k] }  # Initializing hash variable as empty if it does not exist
          other.delete_if { |k, v| !words[k] }         # Remove if not defined in en.yml
          TranslationSupport.write_file(filename, basename, comments, other)
        end
      end
    end
  end
end
