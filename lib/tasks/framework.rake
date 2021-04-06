# Only define freeze and unfreeze tasks in instance mode
unless File.directory? "#{Rails.root}/app"
  namespace :trusty_cms do
    namespace :freeze do
      desc 'Lock this application to the current gems (by unpacking them into vendor/trusty)'
      task :gems do
        require 'rubygems'
        require 'rubygems/gem_runner'

        trusty = (version = ENV['VERSION']) ?
          Gem.cache.search('trusty-cms', "= #{version}").first :
          Gem.cache.search('trusty-cms').max_by { |g| g.version }

        version ||= trusty.version

        unless trusty
          puts "No trusty gem #{version} is installed.  Do 'gem list trusty' to see what you have available."
          exit
        end

        puts "Freezing to the gems for TrustyCms #{trusty.version}"
        rm_rf 'vendor/trusty'

        chdir('vendor') do
          Gem::GemRunner.new.run(['unpack', 'trusty', '--version', "=#{version}"])
          FileUtils.mv(Dir.glob('trusty*').first, 'trusty')
        end
      end

      desc 'Lock to latest Edge TrustyCms or a specific revision with REVISION=X (ex: REVISION=245484e), a tag with TAG=Y (ex: TAG=0.6.6), or a branch with BRANCH=Z (ex: BRANCH=mental)'
      task :edge do
        $verbose = false
        unless system 'git --version'
          warn 'ERROR: Must have git available in the PATH to lock this application to Edge TrustyCms'
          exit 1
        end

        trusty_git = 'git://github.com/pgharts/trusty-cms.git'

        if File.exist?('vendor/trusty_cms/.git/HEAD')
          cd('vendor/trusty') { system 'git checkout master'; system 'git pull origin master' }
        else
          system "git clone #{trusty_git} vendor/trusty"
        end

        if ENV['TAG']
          cd('vendor/trusty') { system "git checkout -b v#{ENV['TAG']} #{ENV['TAG']}" }
        elsif ENV['BRANCH']
          cd('vendor/trusty') { system "git checkout --track -b #{ENV['BRANCH']} origin/#{ENV['BRANCH']}" }
        elsif ENV['REVISION']
          cd('vendor/trusty') { system "git checkout -b REV_#{ENV['REVISION']} #{ENV['REVISION']}" }
        end

        cd('vendor/trusty') { system 'git submodule update --init' }
      end
    end

    desc 'Unlock this application from freeze of gems or edge and return to a fluid use of system gems'
    task :unfreeze do
      rm_rf 'vendor/trusty'
    end

    desc 'Update configs, scripts, html, images, sass, stylesheets and javascripts from TrustyCms.'
    task :update do
      tasks = %w{scripts javascripts configs static_html images sass stylesheets cached_assets bundle}
      tasks = tasks & ENV['ONLY'].split(',') if ENV['ONLY']
      tasks = tasks - ENV['EXCEPT'].split(',') if ENV['EXCEPT']

      tasks.each do |task|
        puts "* Updating #{task}"
        Rake::Task["trusty_cms:update:#{task}"].invoke
      end
    end

    namespace :update do
      desc 'Add new scripts to the instance script/ directory'
      task :scripts do
        local_base = 'script'
        edge_base  = "#{File.dirname(__FILE__)}/../../script"

        local = Dir["#{local_base}/**/*"].reject { |path| File.directory?(path) }
        edge  = Dir["#{edge_base}/**/*"].reject { |path| File.directory?(path) }
        edge  = edge.reject { |f| f =~ /(generate|plugin|destroy)$/ }

        edge.each do |script|
          base_name = script[(edge_base.length + 1)..-1]
          next if local.detect { |path| base_name == path[(local_base.length + 1)..-1] }

          if !File.directory?("#{local_base}/#{File.dirname(base_name)}")
            mkdir_p "#{local_base}/#{File.dirname(base_name)}"
          end
          install script, "#{local_base}/#{base_name}", mode: 0o755
        end
        install "#{File.dirname(__FILE__)}/../generators/instance/templates/instance_generate", "#{local_base}/generate", mode: 0o755
      end

      desc 'Update your javascripts from your current trusty install'
      task :javascripts do
        FileUtils.mkdir_p("#{Rails.root}/public/javascripts/admin/")
        copy_javascripts = proc do |project_dir, scripts|
          scripts.reject! { |s| File.basename(s) == 'overrides.js' } if File.exists?(project_dir + 'overrides.js')
          FileUtils.cp(scripts, project_dir)
        end
        copy_javascripts[Rails.root + '/public/javascripts/', Dir["#{File.dirname(__FILE__)}/../../public/javascripts/*.js"]]
        copy_javascripts[Rails.root + '/public/javascripts/admin/', Dir["#{File.dirname(__FILE__)}/../../public/javascripts/admin/*.js"]]
      end

      desc 'Update the cached assets for the admin UI'
      task :cached_assets do
        TrustyCms::TaskSupport.cache_admin_js
      end

      desc 'Update Gemfile from your current trusty install, backing up if required.'
      task :bundle do
        require 'erb'
        file = "#{Rails.root}/Gemfile"
        tmpfile = "#{Rails.root}/Gemfile.tmp"
        genfile = "#{File.dirname(__FILE__)}/../generators/instance/templates/instance_gemfile"
        backfile = "#{Rails.root}/Gemfile.bak"

        db_gems = {
          'sqlite3' => 'sqlite3',
          'mysql2' => 'mysql2',
          'pg' => 'postgresql',
          'db2' => 'db2',
          'activerecord-sqlserver-adapter' => 'sqlserver',
        }
        active_db_gem = db_gems.keys.find { |g| Gem.loaded_specs[g] } || 'sqlite3'

        File.open(tmpfile, 'w') do |f|
          trusty_version = TrustyCms::VERSION.to_s
          db = db_gems[active_db_gem]
          f.write ERB.new(File.read(genfile)).result(binding)
        end

        unless File.exist?(file) && FileUtils.compare_file(file, tmpfile)
          warning = ''
          if File.exist?(file)
            FileUtils.cp(file, backfile)
            warning << "** WARNING **
Your old Gemfile has been saved as Gemfile.bak. If you had trusty extensions or other gems in that file, please copy those lines to the new file. After checking the Gemfile, please run `bundle install` to update your application."
          else
            warning << "** WARNING **
A Gemfile has been created in your application directory. If you have config.gem entries in your old environment.rb (now .bak), please move them to the Gemfile. When you're happy with it, run `bundle install` to install the gems."
          end
          FileUtils.cp(tmpfile, file)
        end
        FileUtils.rm(tmpfile)
        puts warning
      end

      desc 'Update configuration files from your current trusty install'
      task :configs do
        require 'erb'
        instances = {
          env: "#{Rails.root}/config/environment.rb",
          development: "#{Rails.root}/config/environments/development.rb",
          test: "#{Rails.root}/config/environments/test.rb",
          cucumber: "#{Rails.root}/config/environments/cucumber.rb",
          production: "#{Rails.root}/config/environments/production.rb",
        }
        tmps = {
          env: "#{Rails.root}/config/environment.tmp",
          development: "#{Rails.root}/config/environments/development.tmp",
          test: "#{Rails.root}/config/environments/test.tmp",
          cucumber: "#{Rails.root}/config/environments/cucumber.rb",
          production: "#{Rails.root}/config/environments/production.tmp",
        }
        gens = {
          env: "#{File.dirname(__FILE__)}/../generators/instance/templates/instance_environment.rb",
          development: "#{File.dirname(__FILE__)}/../../config/environments/development.rb",
          test: "#{File.dirname(__FILE__)}/../../config/environments/test.rb",
          cucumber: "#{File.dirname(__FILE__)}/../../config/environments/cucumber.rb",
          production: "#{File.dirname(__FILE__)}/../../config/environments/production.rb",
        }
        backups = {
          env: "#{Rails.root}/config/environment.bak",
          development: "#{Rails.root}/config/environments/development.bak",
          test: "#{Rails.root}/config/environments/test.bak",
          cucumber: "#{Rails.root}/config/environments/cucumber.bak",
          production: "#{Rails.root}/config/environments/production.bak",
        }

        FileUtils.cp("#{File.dirname(__FILE__)}/../generators/instance/templates/instance_boot.rb", Rails.root + '/config/boot.rb')
        FileUtils.cp("#{File.dirname(__FILE__)}/../../config/preinitializer.rb", Rails.root + '/config/preinitializer.rb')
        warning = ''
        %i[env development test cucumber production].each do |env_file|
          File.open(tmps[env_file], 'w') do |f|
            app_name = File.basename(File.expand_path(Rails.root))
            trusty_version = TrustyCms::VERSION.to_s
            f.write ERB.new(File.read(gens[env_file])).result(binding)
          end
          unless File.exist?(instances[env_file]) && FileUtils.compare_file(instances[env_file], tmps[env_file])
            FileUtils.cp(instances[env_file], backups[env_file]) if File.exist?(instances[env_file])
            FileUtils.cp(tmps[env_file], instances[env_file])
            warning << "
- #{instances[env_file].sub(/^#{Rails.root}/, '')}"
          end
          FileUtils.rm(tmps[env_file])
        end
        unless warning.blank?
          puts "** WARNING **
The following files have been changed in TrustyCms. Your originals have
been backed up with .bak extensions. Please copy your customizations to
the new files: #{warning}"
        end
      end

      desc 'Update static HTML files from your current trusty install'
      task :static_html do
        project_dir = Rails.root + '/public/'
        html_files = Dir["#{File.dirname(__FILE__)}/../../public/*.html"].delete_if { |f| f =~ /404.html|500.html/ }
        FileUtils.cp(html_files, project_dir)
      end

      desc 'Update admin and trusty images from your current trusty install'
      task :images do
        %w{admin trusty}.each do |d|
          project_dir = Rails.root + "/public/images/#{d}/"
          FileUtils.mkdir_p(project_dir)
          images = Dir["#{File.dirname(__FILE__)}/../../public/images/#{d}/*"]
          FileUtils.cp_r(images, project_dir)
        end
      end

      desc 'Update admin stylesheets from your current trusty install'
      task :stylesheets do
        project_dir = Rails.root + '/public/stylesheets/admin/'

        copy_stylesheets = proc do |project_dir, styles|
          styles.reject! { |s| File.basename(s) == 'overrides.css' } if File.exists?(project_dir + 'overrides.css')
          FileUtils.cp(styles, project_dir)
        end
        copy_stylesheets[Rails.root + '/public/stylesheets/admin/', Dir["#{File.dirname(__FILE__)}/../../public/stylesheets/admin/*.css"]]
      end

      desc 'Update admin sass files from your current trusty install'
      task :sass do
        copy_sass = proc do |project_dir, sass_files|
          sass_files.reject! { |s| File.basename(s) == 'overrides.sass' } if File.exists?(project_dir + 'overrides.sass') || File.exists?(project_dir + '../overrides.css')
          sass_files.reject! { |s| File.directory?(s) }
          FileUtils.mkpath(project_dir)
          FileUtils.cp(sass_files, project_dir)
        end
        sass_dir = "#{TRUSTY_CMS_ROOT}/public/stylesheets/sass/admin"
        copy_sass[Rails.root + '/public/stylesheets/sass/admin/', Dir["#{sass_dir}/*"]]
        Dir["#{sass_dir}/*"].each do |d|
          if File.directory?(d)
            copy_sass[Rails.root + "/public/stylesheets/sass/admin/#{File.basename(d)}/", Dir["#{d}/*"]]
          end
        end
      end
    end
  end
end
