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
  gem 'devise-two-factor'
  gem 'factory_bot_rails', '6.4.4'
  gem 'file_validators'
  gem 'launchy', '~> 3.0.1'
  gem 'mysql2'
  gem 'paper_trail', '~> 16.0.0'
  gem 'paper_trail-association_tracking', '~> 2.2.1'
  gem 'poltergeist', '~> 1.18.1'
  gem 'pry-byebug'
  gem 'psych', '5.2.2'
  gem 'rails-observers'
  gem 'ransack'
  gem 'rspec-rails', '~> 7.1.1'
  gem 'simplecov'
  gem 'simplecov-lcov'
end
