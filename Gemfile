source 'https://rubygems.org'

# This is the minimum of dependency required to run
# the radiant instance generator, which is (normally)
# the only time the radiant gem functions as an
# application. The instance has its own Gemfile, which
# requires radiant and therefore pulls in every
# dependency mentioned in radiant.gemspec.

gemspec

# When radiant is installed as a gem you can run all of
# its tests and specs from an instance. If you're working
# on radiant itself and you want to run specs from the
# radiant root directory, uncomment the lines below and
# run `bundle install`.

# gemspec
# gem "compass-rails", "~> 1.0.3"

# gem "radiant-archive-extension",             "~> 1.0.7"
# gem "radiant-clipped-extension",             "~> 1.1.0"
# gem "radiant-debug-extension",               "~> 1.0.2"
# gem "radiant-exporter-extension",            "~> 1.1.0"
# gem "radiant-markdown_filter-extension",     "~> 1.0.2"
# gem "radiant-sheets-extension",              "~> 1.1.0.alpha"
# gem "radiant-snippets-extension",            "~> 1.1.0.alpha"
# gem "radiant-site_templates-extension",      "~> 1.0.4"
# gem "radiant-smarty_pants_filter-extension", "~> 1.0.2"
# gem "radiant-textile_filter-extension",      "~> 1.0.4"

group :development, :test do
  gem 'thin',        '~> 1.6.2'
  gem 'pry',         '~> 0.10.0'
  gem 'capybara',    '~> 2.3.0'
  gem 'rspec-rails', '~> 3.0.0'
  gem 'launchy',     '~> 2.4.2'
end
