# This migration comes from trusty_cms_engine (originally 17)
class RenameCreatedByUpdatedByColumns < ActiveRecord::Migration[5.2]
  def self.up
    %w{pages snippets layouts users}.each do |table|
      rename_column table, :created_by, :created_by_id
      rename_column table, :updated_by, :updated_by_id
    end
  end

  def self.down
    %w{pages snippets layouts users}.each do |table|
      rename_column table, :created_by_id, :created_by
      rename_column table, :updated_by_id, :updated_by
    end
  end
end
