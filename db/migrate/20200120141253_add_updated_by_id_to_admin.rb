class AddUpdatedByIdToAdmin < ActiveRecord::Migration[5.2]
  def self.up
    add_column "admins", "updated_by_id", :integer
  end

  def self.down
    remove_column "admins", "updated_by_id"
  end
end