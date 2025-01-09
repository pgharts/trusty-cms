require 'ckeditor'
require 'devise'
require 'ransack'
require 'paper_trail'
require 'paper_trail-association_tracking'

module TrustyCms
  class Engine < Rails::Engine
    isolate_namespace TrustyCms
    paths['app/helpers'] = []
    initializer 'trusty_cms.assets.precompile' do |app|
      app.config.assets.paths << Rails.root.join('../trusty-cms/node_modules')
      app.config.assets.precompile += %w(
        admin/main.css admin.js
        ckeditor/config.js
        ckeditor/contents.css
        ckeditor/config.js
        ckeditor/styles.js
        ckeditor/skins/moono/editor.css
        ckeditor/lang/en.js
        rad_social/rad_screen.css
        rad_social/rad_email.js
        rad_social/rad_widget.js
      )
    end
  end
end
