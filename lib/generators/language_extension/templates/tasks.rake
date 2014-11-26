namespace :radiant do
  namespace :extensions do
    namespace :<%= file_name %> do

      desc "Runs the migration of the <%= localization_name %> language pack"
      task :migrate => :environment do
        require 'trusty_cms/extension_migrator'
        if ENV["VERSION"]
          <%= class_name %>.migrator.migrate(ENV["VERSION"].to_i)
        else
          <%= class_name %>.migrator.migrate
        end
      end

      desc "Copies public assets of the <%= localization_name %> language pack to the instance public/ directory."
      task :update => :environments do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        puts "Copying assets from <%= class_name %>"
        Dir[<%= class_name %>.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(<%= class_name %>.root, '')
          directory = File.dirname(path)
          mkdir_p Rails.root + directory, :verbose => false
          cp file, Rails.root + path, :verbose => false
        end
      end
    end
  end
end
