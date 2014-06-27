class ChangePagesAllowedChildrenCacheToText  < ActiveRecord::Migration
  def self.up
    Page.reset_column_information
    change_column :pages, :allowed_children_cache, :text
  end

  def self.down
    change_column :pages, :allowed_children_cache, :string, :limit => 1500
  end
end
