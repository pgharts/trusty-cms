# This migration comes from trusty_cms_engine (originally 8)
class AddVirtualColumnToPageAgain < ActiveRecord::Migration[5.2]
  def self.up
    add_column "pages", "virtual", :boolean, :null => false, :default => false
  end

  def self.down
    remove_column "pages", "virtual"
  end
end
