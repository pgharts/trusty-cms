module Admin::AssetsHelper

  def automatic_size_descriptions
    Asset.thumbnail_sizes.collect{|k,v| "#{k} (#{(v.to_s).match(/\d+x\d+/)})"}.join(', ')
  end

  def asset_insertion_link(asset)
    radius_tag = asset.asset_type.default_radius_tag || 'link';
    link_to t('clipped_extension.insert'), '#', :class => 'insert_asset', :rel => "#{radius_tag}_#{TrustyCms.config['assets.insertion_size']}_#{asset.id}"
  end

  def asset_attachment_link(asset)
    link_to t("clipped_extension.attach"), new_admin_page_attachment_path(:asset_id => asset.id), :class => 'attach_asset', :rel => "attach_#{asset.id}"
  end

end
