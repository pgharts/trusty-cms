# Installation and Setup

From within the directory containing your TrustyCms instance:

1. Create a new Rails 3 application (i.e. `rails new [project_name]`)

2. Replace most of your gemfile with these gems:
   `gem "trusty-cms", :path => '../trusty-cms'`
   `gem "mysql", "~> 2.9.1"`

3. Run `bundle install`

4. Run the Trusty CMS generator to get the project into shape: `rails g trusty_cms [project_name]`.
   - This will ask you if you want to replace a number of existing files (like application.rb); reply Y to all.

5. Run `bundle exec rake db:create`, then `bundle exec rake db:bootstrap`.

