class RenameFilterColumn < ActiveRecord::Migration[5.2]
  def self.up
    rename_column :page_parts, :filter, :filter_id
    rename_column :snippets, :filter, :filter_id
  end

  def self.down
    rename_column :page_parts, :filter_id, :filter
    rename_column :snippets, :filter_id, :filter
  end
end
