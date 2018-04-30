class AddSiteIdToPages < ActiveRecord::Migration[5.2]
  def self.up
    add_column :pages, :site_id, :integer, required: true
    add_index :pages, :site_id

    Site.all.each do |site|
      homepage = site.homepage
      homepage.site_id = site.id
      homepage.save
      unless homepage.id == Page.root.id
        homepage.descendants.each do |page|
          page.site_id = site.id
          page.save
        end
      end
    end

  end

  def self.down
    remove_index :pages, site_id
    remove_column :pages, :site_id
  end
end
