# Uncomment this if you reference any of your controllers in activate
# require_dependency "application_controller"
require "radiant-<%= file_name %>_language_pack-extension"

class <%= class_name %> < TrustyCms::Extension
  version     TrustyCms<%= class_name %>::VERSION
  description TrustyCms<%= class_name %>::DESCRIPTION
  url         TrustyCms<%= class_name %>::URL

  def activate
  end
end
