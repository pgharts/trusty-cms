namespace :db do
  desc "Migrate schema to version 0 and back up again. WARNING: Destroys all data in tables!!"
  task :remigrate => :environment do
    require 'highline/import'
    if ENV['OVERWRITE'].to_s.downcase == 'true' or agree("This task will destroy any data in the database. Are you sure you want to \ncontinue? [yn] ")

      # Migrate downward
      ActiveRecord::Migrator.migrate("#{TRUSTY_CMS_ROOT}/db/migrate/", 0)

      # Migrate upward
      Rake::Task["db:migrate"].invoke

      # Dump the schema
      Rake::Task["db:schema:dump"].invoke
    else
      say "Task cancelled."
      exit
    end
  end

  task :remigrate => :environment do
    require 'highline/import'
    if ENV['OVERWRITE'].to_s.downcase == 'true' or agree("This task will destroy any data in the database. Are you sure you want to \ncontinue? [yn] ")

      # Migrate downward
      ActiveRecord::Migrator.migrate("#{TRUSTY_CMS_ROOT}/db/migrate/", 0)

      # Migrate upward
      Rake::Task["db:migrate"].invoke

      # Dump the schema
      Rake::Task["db:schema:dump"].invoke
    else
      say "Task cancelled."
      exit
    end
  end

  task :initialize => :environment do
    require 'highline/import'
    if ENV['OVERWRITE'].to_s.downcase == 'true' or agree("This task will destroy any data in the database. Are you sure you want to \ncontinue? [yn] ")

      # We need to erase and remove all existing trusty-cms tables, but we don't want to
      # assume that the administrator has access to drop and create the database.
      # Ideally we should also allow for the presence of non-trusty-cms tables, though
      # that's not a setup anyone would recommend.
      #
      ActiveRecord::Base.connection.tables.each do |table|
        ActiveRecord::Migration[5.2].drop_table table
      end
      Rake::Task["db:migrate"].invoke
    else
      say "Task cancelled."
      exit
    end
  end

  desc "Bootstrap your database for TrustyCms."
  task :bootstrap => :initialize do
    require 'trusty_cms/setup'
    TrustyCms::Setup.bootstrap(
      :admin_name => ENV['ADMIN_NAME'],
      :admin_username => ENV['ADMIN_USERNAME'],
      :admin_password => ENV['ADMIN_PASSWORD'],
      :database_template => ENV['DATABASE_TEMPLATE']
    )
    puts %{
Your TrustyCms application is ready to use. Run `rails s -e production` to
start the server. Your site will then be running at http://localhost:3000

You can access the administrative interface at http://localhost:3000/admin

You may also need to set permissions on the public and cache directories so that
your Web server can access those directories with the user that it runs under.

To add more extensions just add them to your Gemfile and run `bundle install`.

}
  end

  desc "Migrate the database through all available migration scripts (looks for db/migrate/* in trusty-cms, in extensions and in your site) and update db/schema.rb by invoking db:schema:dump. Turn off output with VERBOSE=false."
  task :migrate => [:environment, 'db:migrate:trusty_cms', 'db:migrate:extensions'] do
    ActiveRecord::Migration[5.2].verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
    Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
  end

  namespace :migrate do
    desc "Migrates the database through steps defined in the core trusty-cms distribution. Usual db:migrate options can apply."
    task :trusty_cms => :environment do
      ActiveRecord::Migration[5.2].verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
      Rake::Task['db:migrate'].invoke
    end
  end
end
