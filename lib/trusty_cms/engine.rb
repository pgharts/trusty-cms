module TrustyCms
  class Engine < Rails::Engine
    isolate_namespace TrustyCms

    config.generators do |g|
      g.test_framework :rspec
      g.integration_tool :cucumber
    end
  end
end