require 'active_support'

class AssetType
  def paperclip_processors
    deprecation = ActiveSupport::Deprecation.new()
    deprecation.warn('Paperclip processors will be deprecated soon in favor of ActiveStorage.')

    active_storage_styles
  end

  def paperclip_styles
    deprecation = ActiveSupport::Deprecation.new()
    deprecation.warn('Paperclip styles will be deprecated soon in favor of ActiveStorage.')
  end
end
