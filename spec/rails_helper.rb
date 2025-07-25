# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require 'rspec/rails'
require 'capybara/rails'
require 'capybara/poltergeist'
Capybara.javascript_driver = :poltergeist

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, timeout: 60)
end

require 'database_cleaner'
DatabaseCleaner.strategy = :truncation, {except: %w[config]}

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_paths = ["#{::TRUSTY_CMS_ROOT}/spec/fixtures"]

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  config.before(:suite) do
    TrustyCms::Config.initialize_cache

    configs = [
      ['admin.title', 'TrustyCMS'],
      ['admin.subtitle', 'Publishing for Small Teams'],
      ['defaults.page.parts', 'body, extended'],
      ['defaults.page.status', 'Draft'],
      ['defaults.page.filter', nil],
      ['defaults.page.fields', 'Keywords, Description'],
      ['defaults.snippet.filter', nil],
      ['session_timeout', '1209600'], # 2.weeks.to_s ????
      ['default_locale', 'en'],
    ]
    configs.each do |key, value|
      c = TrustyCms::Config.find_or_initialize_by(key: key)
      c.value = value
      c.save
    end
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
