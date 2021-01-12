require 'test/unit'
# Load the environment
unless defined? TRUSTY_CMS_ROOT
  ENV["Rails.env"] = "test"
  case
  when ENV["RADIANT_ENV_FILE"]
    require ENV["RADIANT_ENV_FILE"]
  when File.dirname(__FILE__) =~ %r{vendor/trusty_cms/vendor/extensions}
    require "#{File.expand_path(File.dirname(__FILE__) + "/../../../../../../")}/config/environment"
  else
    require "#{File.expand_path(File.dirname(__FILE__) + "/../../../../")}/config/environment"
  end
end
require "#{TRUSTY_CMS_ROOT}/test/test_helper"

class Test::Unit::TestCase

  # Include a helper to make testing Radius tags easier
  test_helper :extension_tags

  # Add the fixture directory to the fixture path
  self.fixture_path << File.dirname(__FILE__) + "/fixtures"

  # Add more helper methods to be used by all extension tests here...

end
