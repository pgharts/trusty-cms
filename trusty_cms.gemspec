# -*- encoding: utf-8 -*-
require File.expand_path(__FILE__ + '/../lib/trusty_cms.rb')
Gem::Specification.new do |s|
  s.name = %q{trusty-cms}
  s.version = TrustyCms::Version.to_s
  s.platform = Gem::Platform::RUBY

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = ["TrustyCms CMS dev team"]
  s.default_executable = %q{trusty_cms}
  s.description = %q{TrustyCms is a simple and powerful publishing system designed for small teams.
It is built with Rails and is similar to Textpattern or MovableType, but is
a general purpose content managment system--not merely a blogging engine.}
  s.email = %q{saalon@gmail.com}
  s.executables = ["trusty_cms"]
  s.extra_rdoc_files = ["README.md", "CONTRIBUTORS.md", "CHANGELOG.md", "INSTALL.md", "LICENSE.md"]
  ignores = File.read('.gitignore').split("\n").inject([]) {|a,p| a + Dir[p] }
  s.files = Dir['**/*','.gitignore', 'public/.htaccess', 'log/.keep', 'vendor/extensions/.keep'] - ignores
  s.homepage = %q{https://github.com/pgharts/trusty-cms}
  s.rdoc_options = ["--title", "TrustyCms -- Publishing for Small Teams", "--line-numbers", "--main", "README", "--exclude", "app", "--exclude", "bin", "--exclude", "config", "--exclude", "db", "--exclude", "features", "--exclude", "lib", "--exclude", "log", "--exclude", "pkg", "--exclude", "public", "--exclude", "script", "--exclude", "spec", "--exclude", "test", "--exclude", "tmp", "--exclude", "vendor"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{A no-fluff content management system designed for small teams.}
  s.license = %q{MIT}

  s.add_dependency "tzinfo",          "~> 0.3.31"
  s.add_dependency "rails",           "~> 3.2.18"
  s.add_dependency "jquery-rails",    "~> 3.1.0"
  s.add_dependency "rdoc",            "~> 3.9"
  s.add_dependency "acts_as_tree",    "~> 0.1.1"
  s.add_dependency "bundler",         ">= 1.0.0"
  s.add_dependency "compass-rails",   "~> 2.0.1"
  s.add_dependency "delocalize",      "~> 0.2.3"
  s.add_dependency "haml",            "~> 4.0.5"
  s.add_dependency "haml-rails",      ">= 0.4", "< 0.5" # 0.5 is rails 4+ only
  s.add_dependency "highline",        "~> 1.6.10"
  s.add_dependency "mysql",           "~> 2.9.1"
  s.add_dependency "rack",            "~> 1.4.5"
  s.add_dependency "rack-cache",      "~> 1.2"
  s.add_dependency "rake",            ">= 0.8.7"
  s.add_dependency "radius",          "~> 0.7.3"
  s.add_dependency "RedCloth",        "~> 4.2.0"
  s.add_dependency "will_paginate",   "~> 3.0"
  s.add_dependency "stringex",        "~> 1.3.0"
  s.add_dependency "ckeditor",        "~> 4.1.0"
end
