Rails.application.config.assets.paths << Rails.root.join('node_modules')
Rails.application.config.assets.precompile += ['*.png',
                                               '*.gif']
