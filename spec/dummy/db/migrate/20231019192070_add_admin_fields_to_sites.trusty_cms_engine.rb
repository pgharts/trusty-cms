# This migration comes from trusty_cms_engine (originally 22)
class AddAdminFieldsToSites < ActiveRecord::Migration[5.2]
  def self.up
    add_column :sites, :created_by_id, :integer
    add_column :sites, :created_at, :datetime
    add_column :sites, :updated_by_id, :integer
    add_column :sites, :updated_at, :datetime
    add_column :sites, :subtitle, :string
  end
  
  def self.down
    remove_column :sites, :created_by_id
    remove_column :sites, :created_at
    remove_column :sites, :udpated_by_id
    remove_column :sites, :updated_at
    remove_column :sites, :subtitle
  end
end
