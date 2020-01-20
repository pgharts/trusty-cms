class AddTrustyFieldsToAdmin < ActiveRecord::Migration[5.2]
  def self.up
    add_column "admins", "admin", :boolean
    add_column "admins", "designer", :boolean
    add_column "admins", "content_editor", :boolean
    add_column "admins", "site_id", :integer
  end

  def self.down
    remove_column "admins", "admin"
    remove_column "admins", "designer"
    remove_column "admins", "content_editor"
    remove_column "admins", "site_id"
  end
end