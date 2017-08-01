# Installation and Setup

From within the directory containing your TrustyCMS instance:

1. Create a new Rails 5.0 application (i.e. `rails new [project_name]`)

2. Add the following gems to your Gemfile:
  - gem 'trusty-cms'
  - gem 'rails-observers'

3. Add any additional CMS dependencies. TrustyCMS currently supports:

* gem 'trusty-clipped-extension'
* gem 'trusty-snippets-extension'
* gem 'trusty-layouts-extension'
* gem 'trusty-multi-site-extension'

4. Run `bundle install`

5. Run the Trusty CMS generator to get the project into shape: `rails g trusty_cms [project_name]`.
   - This will ask you if you want to replace a number of existing files (like application.rb); reply Y to all.

6. Run `bundle exec rake db:setup`, then `bundle exec rake db:bootstrap`.
