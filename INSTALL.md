# Installation and Setup

From within the directory containing your TrustyCMS instance:

1. Create a new Rails 5.2 application (i.e. `rails new [project_name]`)

2. Add the following gems to your Gemfile:
  - gem 'trusty-cms'
  - gem 'rails-observers'

3. Run `bundle install`

4. Run the Trusty CMS generator to get the project into shape: `rails g trusty_cms [project_name]`.
   - This will ask you if you want to replace a number of existing files (like application.rb); reply Y to all.

5. add config.extensions = [ :snippets, :clipped, :layouts, :multi_site ] to enable them in application.rb

6. Run `bundle exec rake db:setup`, `bundle exec rake trusty_cms_engine:install:migrations`, then `bundle exec rake db:bootstrap`.
