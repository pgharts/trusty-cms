require 'rake/testtask'

namespace :db do
  namespace :migrate do
    desc 'Run all TrustyCms extension migrations'
    task extensions: :environment do
      require 'trusty_cms/extension_migrator'
      TrustyCms::ExtensionMigrator.migrate_extensions
      Rake::Task['db:schema:dump'].invoke
    end
  end
  namespace :remigrate do
    desc 'Migrate down and back up all TrustyCms extension migrations'
    task extensions: :environment do
      require 'highline/import'
      if agree("This task will destroy any data stored by extensions in the database. Are you sure you want to \ncontinue? [yn] ")
        require 'trusty_cms/extension_migrator'
        TrustyCms::Extension.descendants.each { |ext| ext.migrator.migrate(0) }
        Rake::Task['db:migrate:extensions'].invoke
        Rake::Task['db:schema:dump'].invoke
      end
    end
  end
end

namespace :test do
  desc 'Runs tests on all available TrustyCms extensions, pass EXT=extension_name to test a single extension'
  task extensions: 'db:test:prepare' do
    extensions = TrustyCms.configuration.enabled_extensions
    if ENV['EXT']
      extensions = extensions & [ENV['EXT'].to_sym]
      if extensions.empty?
        puts 'Sorry, that extension is not installed.'
      end
    end
    extensions.each do |extension|
      directory = TrustyCms::ExtensionPath.for(extension)
      if File.directory?(File.join(directory, 'test'))
        chdir directory do
          if RUBY_PLATFORM =~ /win32/
            system "rake.cmd test TRUSTY_ENV_FILE=#{Rails.root}/config/environment"
          else
            system "rake test TRUSTY_ENV_FILE=#{Rails.root}/config/environment"
          end
        end
      end
    end
  end
end

namespace :spec do
  desc 'Runs specs on all available TrustyCms extensions, pass EXT=extension_name to test a single extension'
  task extensions: 'db:test:prepare' do
    extensions = TrustyCms.configuration.enabled_extensions
    if ENV['EXT']
      extensions = extensions & [ENV['EXT'].to_sym]
      if extensions.empty?
        puts 'Sorry, that extension is not installed.'
      end
    end
    extensions.each do |extension|
      directory = TrustyCms::ExtensionPath.for(extension)
      if File.directory?(File.join(directory, 'spec'))
        puts %{\nRunning specs on #{extension} extension from #{directory}/spec\n}
        chdir directory do
          if RUBY_PLATFORM =~ /win32/
            system "rake.cmd spec TRUSTY_ENV_FILE=#{Rails.root}/config/environment"
          else
            system "rake spec TRUSTY_ENV_FILE=#{Rails.root}/config/environment"
          end
        end
      end
    end
  end
end

namespace :trusty_cms do
  namespace :extensions do
    desc 'Runs update asset task for all extensions'
    task update_all: [:environment] do
      extension_update_tasks = TrustyCms.configuration.enabled_extensions.map { |n| "trusty_cms:extensions:#{n}:update" }.select { |t| Rake::Task.task_defined?(t) }
      extension_update_tasks.each { |t| Rake::Task[t].invoke }
    end
  end
end
