# -*- encoding: utf-8 -*-
require File.expand_path(__FILE__ + '/../lib/trusty_cms.rb')
Gem::Specification.new do |s|
  s.name = %q{trusty-cms}
  s.version = TrustyCms::VERSION
  s.platform = Gem::Platform::RUBY

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = ["TrustyCms CMS dev team"]
  s.default_executable = %q{trusty_cms}
  s.description = %q{TrustyCms is a simple and powerful publishing system designed for small teams.
It is built with Rails and is similar to Textpattern or MovableType, but is
a general purpose content managment system--not merely a blogging engine.}
  s.email = %q{saalon@gmail.com}
  s.executables = ["trusty_cms"]
  s.extra_rdoc_files = ["README.md", "CONTRIBUTORS.md", "INSTALL.md", "LICENSE.md"]
  ignores = File.read('.gitignore').split("\n").inject([]) {|a,p| a + Dir[p] }
  s.files = Dir['**/*','.gitignore', 'public/.htaccess', 'log/.keep', 'vendor/extensions/.keep'] - ignores
  s.homepage = %q{https://github.com/pgharts/trusty-cms}
  s.rdoc_options = ["--title", "TrustyCms -- Content Management You Can Trust", "--line-numbers", "--main", "README", "--exclude", "app", "--exclude", "bin", "--exclude", "config", "--exclude", "db", "--exclude", "features", "--exclude", "lib", "--exclude", "log", "--exclude", "pkg", "--exclude", "public", "--exclude", "script", "--exclude", "spec", "--exclude", "test", "--exclude", "tmp", "--exclude", "vendor"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{A no-fluff content management system designed for small teams.}
  s.license = %q{MIT}
  s.test_files = Dir["spec/**/*"]

  s.add_dependency 'acts_as_list',    '~> 0.9.5'
  s.add_dependency 'acts_as_tree',    '~> 2.6.1'
  s.add_dependency 'bundler',         '~> 1.7'
  s.add_dependency 'ckeditor',        '~> 4.2.2'
  s.add_dependency 'compass-rails',   '~> 3.0.2'
  s.add_dependency 'delocalize',      '~> 0.2'
  s.add_dependency 'execjs',          '~> 2.7'
  s.add_dependency 'haml',            '~> 5.0'
  s.add_dependency 'haml-rails',      '~> 1.0.0'
  s.add_dependency 'highline',        '~> 1.7.8'
  s.add_dependency 'kraken-io'
  s.add_dependency 'mysql2'
  s.add_dependency 'paperclip',       '> 5.2'
  s.add_dependency 'rack',            '~> 2.0.1'
  s.add_dependency 'rack-cache',      '~> 1.7'
  s.add_dependency 'rails',           '~> 5.2.0'
  s.add_dependency 'rdoc',            '~> 5.1'
  s.add_dependency 'radius',          '~> 0.7'
  s.add_dependency 'RedCloth',        '4.3.2'
  s.add_dependency 'rake',            '< 11.0'
  s.add_dependency 'roadie-rails'
  s.add_dependency 'stringex',        '~> 2.7.1'
  s.add_dependency 'therubyracer',    '~> 0.12.3'
  s.add_dependency 'tzinfo',          '~> 1.2.3'
  s.add_dependency 'uglifier',        '~> 3.2'
  s.add_dependency 'uuidtools',    '~> 2.1.5'
  s.add_dependency 'will_paginate',   '~> 3.0'

end
