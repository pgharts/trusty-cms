class AddAllowedChildrenCacheToPages < ActiveRecord::Migration[5.2]
  def self.up
    add_column :pages, :allowed_children_cache, :text
  end

  def self.down
    remove_column :pages, :allowed_children_cache
  end
end
