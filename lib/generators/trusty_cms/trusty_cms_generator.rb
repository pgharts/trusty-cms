class TrustyCmsGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  argument :project_name, type: :string, default: "trusty"

  def generate_config

    template "Rakefile.erb", "Rakefile"
    template "config.ru.erb", "config.ru"

    template "boot.rb.erb", "config/boot.rb"
    template "environment.rb.erb", "config/environment.rb"
    template "application.rb.erb", "config/application.rb"
    template "compass.rb.erb", "config/compass.rb"
    template "preinitializer.rb.erb", "config/preinitializer.rb"
    template "routes.rb.erb", "config/routes.rb"
    template "database.yml.erb", "config/database.yml"

    template "environments/development.rb.erb", "config/environments/development.rb"
    template "environments/test.rb.erb", "config/environments/test.rb"
    template "environments/production.rb.erb", "config/environments/production.rb"

    template "initializers/trusty_cms_config.rb.erb", "config/initializers/trusty_cms_config.rb"
    template "initializers/secret_token.rb.erb", "config/initializers/secret_token.rb"
    template "initializers/session_store.rb.erb", "config/initializers/session_store.rb"

    remove_file 'app/controllers/application_controller.rb'
    remove_file 'app/helpers/application_helper.rb'
    remove_file 'app/assets/javascripts/application.js'
    remove_file 'app/views/layouts/application.html.erb'

  end

end
