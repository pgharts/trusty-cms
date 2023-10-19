# This migration comes from trusty_cms_engine (originally 21)
class RemoveSessionExpireFromUsers < ActiveRecord::Migration[5.2]
  def self.up
    remove_column :users, :session_expire
  end

  def self.down
    add_column :users, :session_expire, :datetime
  end
end
