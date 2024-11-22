class CreateSiteUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :admins_sites do |t|
      t.integer :admin_id, null: false, index: true
      t.integer :site_id, null: false, index: true
    end
  end
end
