ENV['RAILS_ENV'] ||= 'test'

# Coverage setup — MUST run before any application code is loaded,
# otherwise Ruby's Coverage library never sees files loaded at boot.
require 'simplecov'
require 'simplecov-lcov'
require 'simplecov_json_formatter'

SimpleCov::Formatter::LcovFormatter.config do |config|
  config.report_with_single_file = true
  config.output_directory = 'coverage'
  config.lcov_file_name = 'lcov.info'
end

SimpleCov.configure do
  add_filter %r{^/lib/generators/}
  add_filter 'lib/trusty_cms/setup.rb'
  add_filter %r{/templates/}   # generated-app boilerplate
end

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::JSONFormatter,   # coverage/coverage.json — consumed by qlty
  SimpleCov::Formatter::LcovFormatter,
  SimpleCov::Formatter::HTMLFormatter
])
SimpleCov.start('rails')

# Now load the application — everything required below is tracked.
require File.expand_path('../dummy/config/environment.rb', __FILE__)

# Test framework setup
require 'rspec/rails'
require 'factory_bot_rails'

include Warden::Test::Helpers
Rails.backtrace_cleaner.remove_silencers!

# Support files and factories
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

FactoryBot.definition_file_paths = [File.expand_path('../factories', __FILE__)]
FactoryBot.find_definitions

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.mock_with :rspec
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"
  config.include Warden::Test::Helpers

  config.before(:each, type: :controller) { @routes = TrustyCms::Engine.routes }
  config.before(:each, type: :routing)    { @routes = TrustyCms::Engine.routes }
end
