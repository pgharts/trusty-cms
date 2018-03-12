Rails.application.config.assets.paths << Rails.root.join('node_modules')
Rails.application.config.assets.precompile += ['*.png',
                                               '*.gif']
Rails.application.config.assets.precompile += %w(admin/assets.css admin/assets_admin.js)
