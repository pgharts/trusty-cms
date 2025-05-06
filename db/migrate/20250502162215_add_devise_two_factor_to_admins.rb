class AddDeviseTwoFactorToAdmins < ActiveRecord::Migration[7.0]
  def change
    add_column :admins, :otp_secret, :string
    add_column :admins, :consumed_timestep, :integer
    add_column :admins, :otp_required_for_login, :boolean
  end
end
