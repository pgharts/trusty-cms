# AssetType keeps its registry in class variables (@@types, @@type_lookup,
# @@default_type memoized by .catchall) with no reset hook, so registrations
# persist for the whole suite. Rather than snapshot/restore around individual
# specs — which desyncs the memoized catchall when a type is removed and later
# re-registered as a fresh object — every spec that needs asset types registers
# the SAME canonical definitions, guarded by `.known?`. Whichever spec runs
# first wins; the rest are no-ops. Definitions here mirror spec/models/asset_spec.rb
# so nothing gets shadowed by a thinner definition.
module AssetTypeRegistry
  def register_standard_asset_types
    unless AssetType.known?(:image)
      AssetType.new(:image, icon: 'image', styles: :standard,
                            extensions: %w[jpg jpeg png gif],
                            mime_types: %w[image/png image/x-png image/jpeg image/pjpeg image/jpg image/gif])
    end
    unless AssetType.known?(:video)
      AssetType.new(:video, icon: 'video',
                            mime_types: %w[video/mp4 video/mpeg video/quicktime video/webm])
    end
    unless AssetType.known?(:document)
      AssetType.new(:document, icon: 'document',
                               mime_types: %w[application/msword application/rtf text/plain text/html])
    end
  end
end

RSpec.configure do |config|
  config.include AssetTypeRegistry
end
