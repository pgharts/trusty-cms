# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "radiant-<%= file_name %>_language_pack-extension"

Gem::Specification.new do |s|
  s.name        = "radiant-<%= file_name %>_language_pack-extension"
  s.version     = TrustyCms<%= class_name %>::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = TrustyCms<%= class_name %>::AUTHORS
  s.email       = TrustyCms<%= class_name %>::EMAIL
  s.homepage    = TrustyCms<%= class_name %>::URL
  s.summary     = TrustyCms<%= class_name %>::SUMMARY
  s.description = TrustyCms<%= class_name %>::DESCRIPTION

  ignores = if File.exist?('.gitignore')
    File.read('.gitignore').split("\n").inject([]) {|a,p| a + Dir[p] }
  else
    []
  end
  s.files         = Dir['**/*'] - ignores
  s.test_files    = Dir['test/**/*','spec/**/*','features/**/*'] - ignores
  # s.executables   = Dir['bin/*'] - ignores
  s.require_paths = ["lib"]
end
