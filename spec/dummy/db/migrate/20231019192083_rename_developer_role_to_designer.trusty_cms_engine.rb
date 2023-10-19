# This migration comes from trusty_cms_engine (originally 20090929164633)
class RenameDeveloperRoleToDesigner < ActiveRecord::Migration[5.2]
  def self.up
    rename_column 'users', 'developer', 'designer'
  end

  def self.down
    rename_column 'users', 'designer', 'developer'
  end
end
