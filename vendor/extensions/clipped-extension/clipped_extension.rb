class ClippedExtension < TrustyCms::Extension
  migrate_from 'Paperclipped', 20100327111216
  require 'admin/assets_helper'

  def activate
    if database_exists?
      if Asset.table_exists?
        Page.send :include, PageAssetAssociations # defines page-asset associations. likely to be generalised soon.
        TrustyCms::AdminUI.send :include, ClippedAdminUI unless defined? admin.asset # defines shards for extension of the asset-admin interface
        Admin::PagesController.send :helper, Admin::AssetsHelper # currently only provides a description of asset sizes
        Page.send :include, AssetTags # radius tags for selecting sets of assets and presenting each one
        AssetType.new :image, :icon => 'image', :default_radius_tag => 'image', :styles => :standard, :extensions => %w[jpg jpeg png gif webp avif], :mime_types => %w[image/png image/x-png image/jpeg image/pjpeg image/jpg image/gif image/webp image/avif]
        AssetType.new :video, :icon => 'video', :styles => :standard, :mime_types => %w[video/mp4 video/webm video/quicktime video/mpeg video/ogg video/mp2t application/x-mp4]
        AssetType.new :audio, :icon => 'audio', :mime_types => %w[audio/mpeg audio/mpg audio/ogg audio/mp4 audio/wav audio/x-wav application/ogg audio/flac]
        AssetType.new :pdf, :icon => 'pdf', :extensions => %w{pdf}, :mime_types => %w[application/pdf application/x-pdf], :styles => :standard
        AssetType.new :other, :icon => 'unknown'

        admin.asset ||= TrustyCms::AdminUI.load_default_asset_regions # loads the shards defined in AssetsAdminUI
        admin.page.edit.add :form, 'assets', :after => :edit_page_parts # adds the asset-attachment picker to the page edit view
        admin.page.edit.add :main, 'asset_popups', :after => :edit_popups # adds the asset-attachment picker to the page edit view
        admin.page.edit.asset_popups.concat %w{upload_asset attach_asset}
        admin.configuration.show.add :trusty_config, 'admin/configuration/clipped_show', :after => 'defaults'
        admin.configuration.edit.add :form, 'admin/configuration/clipped_edit', :after => 'edit_defaults'

        tab "Assets", :after => "Content" do
          add_item "All", "/admin/assets"
        end
      end
    end
  end

  def deactivate

  end

  def database_exists?
    ActiveRecord::Base.connection
  rescue ActiveRecord::NoDatabaseError
    false
  else
    true
  end

end
