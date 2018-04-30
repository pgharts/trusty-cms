class ChangePagesAllowedChildrenCacheToText  < ActiveRecord::Migration[5.2]
  def self.up
    change_column :pages, :allowed_children_cache, :text
  end

  def self.down
    change_column :pages, :allowed_children_cache, :string, :limit => 1500
  end
end
