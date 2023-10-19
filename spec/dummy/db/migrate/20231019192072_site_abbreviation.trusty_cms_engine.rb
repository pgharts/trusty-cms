# This migration comes from trusty_cms_engine (originally 24)
class SiteAbbreviation < ActiveRecord::Migration[5.2]
  def self.up
    add_column :sites, :abbreviation, :string
  end

  def self.down
    remove_column :sites, :abbreviation
  end
end
