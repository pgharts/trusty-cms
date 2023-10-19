# This migration comes from trusty_cms_engine (originally 20160527141249)
class AddPasswordResetToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :password_reset_token, :string
    add_column :users, :password_reset_sent_at, :datetime
  end
end
