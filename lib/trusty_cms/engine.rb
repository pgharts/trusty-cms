module TrustyCms
  class Engine < Rails::Engine
    paths["app/helpers"] = []
    initializer "trusty_cms.assets.precompile" do |app|
      app.config.assets.precompile += %w(admin/main.css admin.js ckeditor/contents.css ckeditor/config.js ckeditor/skins/moono/editor.css ckeditor/lang/en.js)
    end
  end
end

require 'ckeditor'
