unless defined? TRUSTY_CMS_ROOT
  ENV["Rails.env"] = "test"
  case
  when ENV.fetch('RADIANT_ENV_FILE')
    require ENV.fetch('RADIANT_ENV_FILE')
  when File.dirname(__FILE__) =~ %r{vendor/trusty_cms/vendor/extensions}
    require "#{File.expand_path(File.dirname(__FILE__) + "/../../../../../../")}/config/environment"
  else
    require "#{File.expand_path(File.dirname(__FILE__) + "/../../../../")}/config/environment"
  end
end
require "#{TRUSTY_CMS_ROOT}/spec/spec_helper"

Dataset::Resolver.default << (File.dirname(__FILE__) + "/datasets")
# Include any datasets from loaded extensions
TrustyCms::Extension.descendants.each do |extension|
  if File.directory?(extension.root + "/spec/datasets")
    Dataset::Resolver.default << (extension.root + "/spec/datasets")
  end
end

if File.directory?(File.dirname(__FILE__) + "/matchers")
  Dir[File.dirname(__FILE__) + "/matchers/*.rb"].each {|file| require file }
end

Spec::Runner.configure do |config|
  # config.use_transactional_fixtures = true
  # config.use_instantiated_fixtures  = false
  # config.fixture_path = Rails.root + '/spec/fixtures'

  # You can declare fixtures for each behaviour like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so here, like so ...
  #
  #   config.global_fixtures = :table_a, :table_b
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
end
