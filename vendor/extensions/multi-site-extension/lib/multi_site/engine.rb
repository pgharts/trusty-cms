module MultiSite
  class Engine < Rails::Engine
    paths["app/helpers"] = []

    initializer "multi_site.assets.precompile" do |app|
      app.config.assets.precompile += %w(admin/multi_site.css)
    end

  end
end
