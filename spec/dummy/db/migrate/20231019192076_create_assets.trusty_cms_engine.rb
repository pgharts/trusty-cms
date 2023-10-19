# This migration comes from trusty_cms_engine (originally 28)
class CreateAssets < ActiveRecord::Migration[5.2]
  def self.up
    create_table :assets do |t|
      t.string :caption, :title
    end
    
  end
  
  def self.down
    drop_table :assets
  end
end