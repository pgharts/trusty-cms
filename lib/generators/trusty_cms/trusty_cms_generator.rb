class TrustyCmsGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
  argument :project_name, type: :string, default: "trusty"

  def generate_config
    template "boot.rb.erb", "config/boot.rb"
    template "environment.rb.erb", "config/environment.rb"
    template "application.rb.erb", "config/application.rb"
    template "compass.rb.erb", "config/compass.rb"
    template "preinitializer.rb.erb", "config/preinitializer.rb"
    template "routes.rb.erb", "config/routes.rb"

    template "environments/development.rb.erb", "config/environments/development.rb"
    template "environments/test.rb.erb", "config/environments/test.rb"
    template "environments/production.rb.erb", "config/environments/production.rb"

    template "initializers/trusty_cms_config.rb.erb", "config/initializers/trusty_cms_config.rb"
    template "initializers/secret_token.rb.erb", "config/initializers/secret_token.rb"
  end

end
