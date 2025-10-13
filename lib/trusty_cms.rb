require 'trusty_cms/version'
require 'trusty_cms/engine'

module TrustyCms
  mattr_accessor :editor_stylesheets, default: []
  mattr_accessor :editor_style_definitions, default: []
end

TRUSTY_CMS_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..')) unless defined? TRUSTY_CMS_ROOT

