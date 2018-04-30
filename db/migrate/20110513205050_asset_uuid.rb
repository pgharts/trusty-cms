class AssetUuid < ActiveRecord::Migration[5.2]
  def self.up
    add_column :assets, :uuid, :string
    Asset.reset_column_information
    Asset.all.each { |a| a.save! }    # triggers assign_uuid
  end

  def self.down
    remove_column :assets, :uuid
  end
end
