# This migration comes from trusty_cms_engine (originally 9)
class AddContentTypeFieldToLayout < ActiveRecord::Migration[5.2]
  def self.up
    add_column "layouts", "content_type", :string, :limit => 40
  end

  def self.down
    remove_column "layouts", "content_type"
  end
end
