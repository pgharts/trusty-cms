# This migration comes from trusty_cms_engine (originally 20090226140109)
class AddUserLanguage < ActiveRecord::Migration[5.2]
  def self.up
    add_column :users, :language, :string
  end

  def self.down
    remove_column :users, :language
  end
end
