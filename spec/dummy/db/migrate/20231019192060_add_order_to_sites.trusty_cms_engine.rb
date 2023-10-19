# This migration comes from trusty_cms_engine (originally 11)
class AddOrderToSites < ActiveRecord::Migration[5.2]
  def self.up
    add_column :sites, :position, :integer, :default => 0
  end
  
  def self.down
    remove_column :sites, :position
  end
end
