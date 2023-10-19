# This migration comes from trusty_cms_engine (originally 7)
class RemoveVirtualColumnFromPage < ActiveRecord::Migration[5.2]
  def self.up
    remove_column "pages", "virtual"
  end

  def self.down
    add_column "pages", "virtual", :boolean, :null => false, :default => false
  end
end
