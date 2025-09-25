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
      engine_builds = Rails.root.join("app/assets/builds")
      app.config.assets.paths << engine_builds
      app.config.assets.precompile += %w(
        admin/main.css
        admin.js
        trusty-cms-manifest.js
      )
    end
  end
end
