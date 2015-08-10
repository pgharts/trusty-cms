module TrustyCms
  class Engine < Rails::Engine
    paths["app/helpers"] = []
    initializer "trusty_cms.assets.precompile" do |app|
      app.config.assets.precompile += %w(admin/main.css admin.js ckeditor/config.js ckeditor/contents.css ckeditor/config.js ckeditor/styles.js ckeditor/skins/moono/editor.css ckeditor/lang/en.js)
    end

    config.generators do |g|
      g.test_framework      :rspec,        :fixture => false
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
      g.assets false
      g.helper false
    end
  end
end

require 'ckeditor'
