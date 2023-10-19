# This migration comes from trusty_cms_engine (originally 20100810151922)
class AddFieldNameIndex < ActiveRecord::Migration[5.2]
  def self.up
    remove_index :page_fields, :page_id
    add_index :page_fields, [:page_id, :name, :content]
  end

  def self.down
    remove_index :page_fields, [:page_id, :name, :content]
    add_index :page_fields, :page_id
  end
end
