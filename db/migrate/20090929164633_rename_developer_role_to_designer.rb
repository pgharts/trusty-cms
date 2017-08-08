class RenameDeveloperRoleToDesigner < ActiveRecord::Migration[5.1]
  def self.up
    rename_column 'users', 'developer', 'designer'
  end

  def self.down
    rename_column 'users', 'designer', 'developer'
  end
end
