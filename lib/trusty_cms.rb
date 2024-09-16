TRUSTY_CMS_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..')) unless defined? TRUSTY_CMS_ROOT

unless defined? TrustyCms::VERSION
  module TrustyCms
    VERSION = '6.1.3'.freeze
  end
end

