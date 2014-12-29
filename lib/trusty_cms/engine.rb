module TrustyCms
  class Engine < Rails::Engine
    paths["app/helpers"] = []
    initializer "trusty_cms.assets.precompile" do |app|
      app.config.assets.precompile += %w(admin/main.css admin.js admin/ckeditor/config.js admin/ckeditor/contents.css)
    end
  end
end

require 'ckeditor'
