module TrustyCms
  class Engine < Rails::Engine
    paths["app/helpers"] = []
  end
end

require 'ckeditor'
