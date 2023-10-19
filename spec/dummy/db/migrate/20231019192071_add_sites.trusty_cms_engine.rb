# This migration comes from trusty_cms_engine (originally 23)
class AddSites < ActiveRecord::Migration[5.2]
  def self.up
    [:layouts, :snippets, :users].each do |table|
      add_column table, :site_id, :integer
    end
  end

  def self.down
    [:layouts, :snippets, :users].each do |table|
      add_column table, :site_id, :integer
    end
  end
end
