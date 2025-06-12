ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../dummy/config/environment.rb', __FILE__)

require 'simplecov'
require 'simplecov-lcov'

require 'rspec/rails'
require 'factory_bot_rails'

SimpleCov::Formatter::LcovFormatter.config do |config|
  config.report_with_single_file = true
  config.output_directory = 'coverage'
  config.lcov_file_name = 'lcov.info'
end

SimpleCov.formatter = SimpleCov::Formatter::LcovFormatter

SimpleCov.start('rails')
include Warden::Test::Helpers

Rails.backtrace_cleaner.remove_silencers!

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
