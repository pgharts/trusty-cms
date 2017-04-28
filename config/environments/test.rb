TrustyCms::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # The test environment is used exclusively to run your application's
  # test suite.  You never need to work with it otherwise.  Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs.  Don't rely on the data there!
  config.cache_classes = true
  config.eager_load = false

  # ensure test extensions are loaded
  # test_extension_dir = File.join(File.expand_path(TRUSTY_CMS_ROOT), 'test', 'fixtures', 'extensions')
  # config.extension_paths.unshift test_extension_dir
  # config.extension_paths.uniq!
  # if !config.extensions.include?(:all)
  #   config.extensions.concat(Dir["#{test_extension_dir}/*"].sort.map {|x| File.basename(x).sub(/^\d+_/,'')})
  #   config.extensions.uniq!
  # end

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils    = true

  # Show full error reports and disable caching
  config.consider_all_requests_local = true
  config.action_controller.perform_caching             = false


  # Raise an ActiveModel::MassAssignmentSecurity::Error any time
  # something is mass-assigned that shouldn't be for ease in debugging.
  # config.active_record.mass_assignment_sanitizer = :strict

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection    = false

  # Tell ActionMailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Configure static asset server for tests with Cache-Control for performance
  config.public_file_server.enabled = true
  config.public_file_server.headers = { 'Cache-Control' => 'public, max-age=3600' }

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

  config.active_support.deprecation = :stderr
end
