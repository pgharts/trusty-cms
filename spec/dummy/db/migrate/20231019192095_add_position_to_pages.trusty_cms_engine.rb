# This migration comes from trusty_cms_engine (originally 20161027141250)
class AddPositionToPages < ActiveRecord::Migration[5.2]
  def self.up
    unless column_exists? :pages, :position
      add_column :pages, :position, :integer
      Page.reset_column_information
      say_with_time("Putting all pages in a default order...") do
        ActiveRecord::Base.record_timestamps = false
        Page.where(parent_id: nil).each do |p|
          put_children_into_list(p)
        end
        ActiveRecord::Base.record_timestamps = true
      end
    end
  end

  def self.down
    remove_column :pages, :position
  end

  def self.put_children_into_list(page)
    page.children.order("title asc").each_with_index do |pg, idx|
      pg.update_attribute('position', idx + 1)
      put_children_into_list(pg)
    end
  end
end