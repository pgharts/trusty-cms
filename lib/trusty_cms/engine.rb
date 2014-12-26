module TrustyCms
  class Engine < Rails::Engine
    paths["app/helpers"] = []
    initializer "trusty_cms.assets.precompile" do |app|
      app.config.assets.precompile += %w(admin/main.scss admin.js)
    end
  end
end

require 'ckeditor'
