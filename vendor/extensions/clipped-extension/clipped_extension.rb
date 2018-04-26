class ClippedExtension < TrustyCms::Extension
  migrate_from 'Paperclipped', 20100327111216
  require 'admin/assets_helper'

  def activate
    if database_exists?
      if Asset.table_exists?
        Page.send :include, PageAssetAssociations                                          # defines page-asset associations. likely to be generalised soon.
        TrustyCms::AdminUI.send :include, ClippedAdminUI unless defined? admin.asset         # defines shards for extension of the asset-admin interface
        Admin::PagesController.send :helper, Admin::AssetsHelper                           # currently only provides a description of asset sizes
        Page.send :include, AssetTags                                                      # radius tags for selecting sets of assets and presenting each one
        UserActionObserver.instance.send :add_observer!, Asset                             # the usual creator- and updater-stamping

        AssetType.new :image, :icon => 'image', :default_radius_tag => 'image', :processors => [:thumbnail], :styles => :standard, :extensions => %w[jpg jpeg png gif], :mime_types => %w[image/png image/x-png image/jpeg image/pjpeg image/jpg image/gif]
        AssetType.new :video, :icon => 'video', :processors => [:frame_grab], :styles => :standard, :mime_types => %w[application/x-mp4 video/mpeg video/quicktime video/x-la-asf video/x-ms-asf video/x-msvideo video/x-sgi-movie video/x-flv flv-application/octet-stream video/3gpp video/3gpp2 video/3gpp-tt video/BMPEG video/BT656 video/CelB video/DV video/H261 video/H263 video/H263-1998 video/H263-2000 video/H264 video/JPEG video/MJ2 video/MP1S video/MP2P video/MP2T video/mp4 video/MP4V-ES video/MPV video/mpeg4 video/mpeg4-generic video/nv video/parityfec video/pointer video/raw video/rtx video/ogg video/webm]
        AssetType.new :audio, :icon => 'audio', :mime_types => %w[audio/mpeg audio/mpg audio/ogg application/ogg audio/x-ms-wma audio/vnd.rn-realaudio audio/x-wav]
        AssetType.new :pdf, :icon => 'pdf', :processors => [:thumbnail], :extensions => %w{pdf}, :mime_types => %w[application/pdf application/x-pdf], :styles => :standard
        AssetType.new :document, :icon => 'document', :mime_types => %w[application/msword application/rtf application/vnd.ms-excel application/vnd.ms-powerpoint application/vnd.ms-project application/vnd.ms-works text/plain text/html]
        AssetType.new :other, :icon => 'unknown'

        admin.asset ||= TrustyCms::AdminUI.load_default_asset_regions                        # loads the shards defined in AssetsAdminUI
        admin.page.edit.add :form, 'assets', :after => :edit_page_parts                    # adds the asset-attachment picker to the page edit view
        admin.page.edit.add :main, 'asset_popups', :after => :edit_popups                  # adds the asset-attachment picker to the page edit view
        admin.page.edit.asset_popups.concat %w{upload_asset attach_asset}
        admin.configuration.show.add :trusty_config, 'admin/configuration/clipped_show', :after => 'defaults'
        admin.configuration.edit.add :form,   'admin/configuration/clipped_edit', :after => 'edit_defaults'

        if TrustyCms::Config.table_exists? && TrustyCms::config["paperclip.command_path"]    # This is needed for testing if you are using mod_rails
          Paperclip.options[:command_path] = TrustyCms::config["paperclip.command_path"]
        end

        tab "Assets", :after => "Content" do
          add_item "All", "/admin/assets/"
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
