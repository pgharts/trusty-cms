require 'active_support'

class AssetType
  def paperclip_processors
    ActiveSupport::Deprecation.warn('Paperclip processors will be deprecated soon in favor of ActiveStorage.')

    active_storage_styles
  end

  def paperclip_styles
    ActiveSupport::Deprecation.warn('Paperclip styles will be deprecated soon in favor of ActiveStorage.')
  end
end