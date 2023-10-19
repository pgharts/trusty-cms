# This migration comes from trusty_cms_engine (originally 30)
class CreateUserObserver < ActiveRecord::Migration[5.2]
  def self.up
    add_column :assets, :created_by, :integer
    add_column :assets, :updated_by, :integer
    add_column :assets, :created_at, :datetime
    add_column :assets, :updated_at, :datetime
  end
  
  def self.down
    remove_column :assets, :created_by
    remove_column :assets, :updated_by
  end
end