TRUSTY_CMS_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..')) unless defined? TRUSTY_CMS_ROOT

unless defined? TrustyCms::VERSION
  module TrustyCms
    VERSION = '4.1.4'.freeze
  end
end
