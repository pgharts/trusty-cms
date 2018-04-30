class CreateSites < ActiveRecord::Migration[5.2]
  def self.up
    create_table :sites do |t|
      t.column :name, :string
      t.column :domain, :string
      t.column :homepage_id, :integer
    end
  end

  def self.down
    drop_table :sites
  end
end
