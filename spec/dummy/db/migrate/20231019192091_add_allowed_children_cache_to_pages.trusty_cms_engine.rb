# This migration comes from trusty_cms_engine (originally 20110902203823)
class AddAllowedChildrenCacheToPages < ActiveRecord::Migration[5.2]
  def self.up
    add_column :pages, :allowed_children_cache, :text
  end

  def self.down
    remove_column :pages, :allowed_children_cache
  end
end
