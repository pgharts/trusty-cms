# This migration comes from trusty_cms_engine (originally 27)
class AddBaseDomainToSites < ActiveRecord::Migration[5.2]
  def self.up
    add_column :sites, :base_domain, :string
  end
  
  def self.down
    remove_column :sites, :base_domain
  end
end
