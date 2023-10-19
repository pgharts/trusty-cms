# This migration comes from trusty_cms_engine (originally 20100805154952)
class AddPageFields < ActiveRecord::Migration[5.2]
  def self.up
    create_table :page_fields do |t|
      t.integer :page_id
      t.string :name
      t.string :content
    end
    add_index :page_fields, :page_id
  end

  def self.down
    remove_index :page_fields, :page_id
    drop_table :page_fields
  end
end
