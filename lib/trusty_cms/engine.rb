module TrustyCms
  class Engine < Rails::Engine
    paths["config/initializers"] = []
    paths["app/helpers"]         = []
  end
end
