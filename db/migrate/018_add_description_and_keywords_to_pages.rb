class AddDescriptionAndKeywordsToPages < ActiveRecord::Migration[5.2]
  def self.up
    add_column :pages, :description, :string
    add_column :pages, :keywords, :string
  end

  def self.down
    remove_column :pages, :keywords
    remove_column :pages, :description
  end
end
