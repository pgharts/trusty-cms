# This migration comes from trusty_cms_engine (originally 20100805155020)
class ConvertPageMetas < ActiveRecord::Migration[5.2]
  def self.up
    remove_column :pages, :keywords
    remove_column :pages, :description
  end

  def self.down
    add_column :pages, :description, :string
    add_column :pages, :keywords, :string
  end
end
