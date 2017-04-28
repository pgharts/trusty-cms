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
  gem 'pry',              '~> 0.10.0'
  gem 'capybara',         '~> 2.13.0'
  gem 'rspec-rails'
  gem 'launchy',          '~> 2.4.2'
  gem 'database_cleaner', '~> 1.5.3'
  gem 'poltergeist',      '~> 1.14.0'
  gem 'factory_girl_rails', '~> 4.6.0'
  gem 'rails-observers', :git => 'https://github.com/rails/rails-observers'
  gem 'protected_attributes_continued'
  gem 'pry-rails'
  gem 'mysql2',          '~> 0.4.2'
  gem 'pry-byebug'
  gem 'simplecov'
  gem 'codeclimate-test-reporter'
end
gem 'nokogiri', '>= 1.6.8'
