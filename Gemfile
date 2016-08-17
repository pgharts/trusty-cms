source 'https://rubygems.org'

# This is the minimum of dependency required to run
# the trusty-cms instance generator, which is (normally)
# the only time the trusty gem functions as an
# application. The instance has its own Gemfile, which
# requires trusty and therefore pulls in every
# dependency mentioned in trusty.gemspec.

gem 'trustygems', '~> 0.2.0'

gemspec

# When trusty is installed as a gem you can run all of
# its tests and specs from an instance. If you're working
# on trusty itself and you want to run specs from the
# trusty root directory, uncomment the lines below and
# run `bundle install`.

# gemspec
# gem "compass-rails", "~> 1.0.3"

# gem "trusty-clipped-extension",             "~> 2.0.13"
# gem "trusty-snippets-extension",            "~> 2.0.7"
# gem "trusty-multi-site-extension", 		  "~> 2.0.11"
# gem "trusty-reorder-extension",             "~> 2.0.6"
# gem "trusty-layouts-extension",      		  "~> 2.0.4"


group :development, :test do
  gem 'compass-rails',   '~> 2.0.1'
  gem 'thin',             '~> 1.6.2'
  gem 'pry',              '~> 0.10.0'
  gem 'capybara',         '~> 2.3.0'
  gem 'rspec-rails',      '~> 3.0.0'
  gem 'launchy',          '~> 2.4.2'
  gem 'database_cleaner', '~> 1.3.0'
  gem 'poltergeist',      '~> 1.5.1'
  gem 'ckeditor',        '~> 4.1.0'
  gem 'factory_girl_rails', '~> 4.6.0'
  gem 'rails-observers'
  gem 'protected_attributes'
  gem 'pry-rails'
  gem 'mysql2',          '~> 0.4.2'
  gem 'pry-byebug'
  gem 'simplecov'
end
gem 'nokogiri', '>= 1.6.8'
