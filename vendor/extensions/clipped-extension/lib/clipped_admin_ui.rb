module ClippedAdminUI

 def self.included(base)
   base.class_eval {
      attr_accessor :asset
      alias_method :assets, :asset

        def load_default_asset_regions
          OpenStruct.new.tap do |asset|
            asset.edit = TrustyCms::AdminUI::RegionSet.new do |edit|
              edit.main.concat %w{edit_header edit_form edit_regenerate}
              edit.form.concat %w{edit_title edit_metadata}
            end
            asset.new = asset.edit
            asset.index = TrustyCms::AdminUI::RegionSet.new do |index|
              index.top.concat %w{filters}
              index.bottom.concat %w{}
              index.thead.concat %w{thumbnail_header content_type_header actions_header}
              index.tbody.concat %w{thumbnail_cell title_cell content_type_cell actions_cell}
              index.paginate
            end
            asset.remove = asset.index
          end
        end
   }
  end
end

