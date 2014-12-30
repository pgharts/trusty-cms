TRUSTY_CMS_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "..")) unless defined? TRUSTY_CMS_ROOT

unless defined? TrustyCms::Version
  module TrustyCms
    module Version
      Major = '1'
      Minor = '1'
      Tiny  = '19'
      Patch = nil # set to nil for normal release

      class << self
        def to_s
          [Major, Minor, Tiny, Patch].delete_if{|v| v.nil? }.join('.')
        end
        alias :to_str :to_s
      end
    end
  end
end
