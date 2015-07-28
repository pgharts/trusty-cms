class ConvertPageMetas < ActiveRecord::Migration
  def self.up
    remove_column :pages, :keywords
    remove_column :pages, :description
  end

  def self.down
    add_column :pages, :description, :string
    add_column :pages, :keywords, :string
  end
end
