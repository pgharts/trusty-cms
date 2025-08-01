# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require File.expand_path(__FILE__ + '/../lib/trusty_cms/version.rb')
Gem::Specification.new do |s|
  s.required_ruby_version = '>= 3.0.5'
  s.name = 'trusty-cms'
  s.version = TrustyCms::VERSION
  s.platform = Gem::Platform::RUBY

  s.required_rubygems_version = Gem::Requirement.new('> 1.3.1') if s.respond_to? :required_rubygems_version=
  s.authors = ['TrustyCms CMS dev team']
  s.description = 'TrustyCms is a simple and powerful publishing system designed for small teams.
It is built with Rails and is similar to Textpattern or MovableType, but is
a general purpose content management system--not merely a blogging engine.'
  s.email = 'webteam@trustarts.org'
  s.executables = ['trusty_cms']
  s.extra_rdoc_files = ['README.md', 'INSTALL.md', 'LICENSE.md']
  s.files = Dir['**/*', '.gitignore', 'public/.htaccess', 'log/.keep', 'vendor/extensions/.keep']
  s.homepage = 'https://github.com/pgharts/trusty-cms'
  s.rdoc_options = ['--title', 'TrustyCms -- Content Management You Can Trust', '--line-numbers', '--main', 'README', '--exclude', 'app', '--exclude', 'bin', '--exclude',
                    'config', '--exclude', 'db', '--exclude', 'features', '--exclude', 'lib', '--exclude', 'log', '--exclude', 'pkg', '--exclude', 'public', '--exclude', 'script', '--exclude', 'spec', '--exclude', 'test', '--exclude', 'tmp', '--exclude', 'vendor']
  s.require_paths = ['lib']
  s.rubygems_version = '1.3.7'
  s.summary = 'A no-fluff content management system designed for small teams.'
  s.license = 'MIT'
  s.test_files = Dir['spec/**/*']
  s.add_dependency 'activestorage-validator'
  s.add_dependency 'acts_as_list', '>= 0.9.5', '< 1.3.0'
  s.add_dependency 'acts_as_tree', '~> 2.9.1'
  s.add_dependency 'base64'
  s.add_dependency 'bigdecimal'
  s.add_dependency 'ckeditor', '>= 4.2.2', '< 4.4.0'
  s.add_dependency 'delocalize', '>= 0.2', '< 2.0'
  s.add_dependency 'devise'
  s.add_dependency 'devise-two-factor'
  s.add_dependency 'diffy'
  s.add_dependency 'drb'
  s.add_dependency 'execjs', '~> 2.7'
  s.add_dependency 'haml', '~> 6.3.0'
  s.add_dependency 'haml-rails', '~> 2.1'
  s.add_dependency 'highline', '>= 1.7.8', '< 3.2.0'
  s.add_dependency 'image_processing'
  s.add_dependency 'kraken-io'
  s.add_dependency 'mini_racer'
  s.add_dependency 'mutex_m'
  s.add_dependency 'mysql2'
  s.add_dependency 'paper_trail', '~> 16.0.0'
  s.add_dependency 'paper_trail-association_tracking', '~> 2.2.1'
  s.add_dependency 'psych', '5.2.2'
  s.add_dependency 'rack', '>= 2.0.1', '< 3.2.0'
  s.add_dependency 'rack-cache', '~> 1.7'
  s.add_dependency 'radius', '~> 0.8'
  s.add_dependency 'rails', '~> 7.2.2.1'
  s.add_dependency 'rake', '< 14.0'
  s.add_dependency 'ransack', '~> 4.2.1'
  s.add_dependency 'rdoc', '>= 5.1', '< 7.0'
  s.add_dependency 'RedCloth', '4.3.3'
  s.add_dependency 'roadie-rails'
  s.add_dependency 'rqrcode'
  s.add_dependency 'sass-rails'
  s.add_dependency 'stringex', '>= 2.7.1', '< 2.9.0'
  s.add_dependency 'tzinfo', '>= 1.2.3', '< 2.1.0'
  s.add_dependency 'uglifier', '>= 3.2', '< 5.0'
  s.add_dependency 'uri'
  s.add_dependency 'will_paginate', '>= 3', '< 5'
end
