source 'https://rubygems.org'

# This is the minimum of dependency required to run
# the trusty-cms instance generator, which is (normally)
# the only time the trusty gem functions as an
# application. The instance has its own Gemfile, which
# requires trusty and therefore pulls in every
# dependency mentioned in trusty.gemspec.

gem 'trustygems', '~> 0.2.0'

gemspec

group :development, :test do
  gem 'activestorage-validator'
  gem 'acts_as_list'
  gem 'database_cleaner'
  gem 'factory_bot_rails', '6.4.2'
  gem 'file_validators'
  gem 'launchy', '~> 2.5.0'
  gem 'mysql2'
  gem 'poltergeist', '~> 1.18.1'
  gem 'pry-byebug'
  gem 'psych', '5.1.1.1'
  gem 'rails-observers'
  gem 'ransack'
  gem 'rspec-rails'
  gem 'simplecov'
end
