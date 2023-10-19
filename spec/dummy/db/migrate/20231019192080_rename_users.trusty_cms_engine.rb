# This migration comes from trusty_cms_engine (originally 32)
class RenameUsers < ActiveRecord::Migration[5.2]
  
  def self.up
    rename_column :assets, :created_by, :created_by_id
    rename_column :assets, :updated_by, :updated_by_id
  end

  def self.down
    rename_column :assets, :created_by_id, :created_by
    rename_column :assets, :updated_by_id, :updated_by
  end
  
end