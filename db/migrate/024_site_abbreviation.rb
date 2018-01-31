class SiteAbbreviation < ActiveRecord::Migration[5.1]
  def self.up
    add_column :sites, :abbreviation, :string
  end

  def self.down
    remove_column :sites, :abbreviation
  end
end
