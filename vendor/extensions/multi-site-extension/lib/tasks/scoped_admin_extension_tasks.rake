namespace :radiant do
  namespace :extensions do
    namespace :scoped_admin do
      
      desc "Runs the migration of the Scoped Admin extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          ScopedAdminExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          ScopedAdminExtension.migrator.migrate
        end
      end
      
      desc "Copies public assets of the Scoped Admin to the instance public/ directory."
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        puts "Copying assets from ScopedAdminExtension"
        Dir[ScopedAdminExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(ScopedAdminExtension.root, '')
          directory = File.dirname(path)
          mkdir_p RAILS_ROOT + directory
          cp file, RAILS_ROOT + path
        end
      end  
    end
  end
end
