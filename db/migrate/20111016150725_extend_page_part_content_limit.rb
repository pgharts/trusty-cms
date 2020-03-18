class ExtendPagePartContentLimit < ActiveRecord::Migration[5.2]
  def self.up
    if ActiveRecord::Base.connection.adapter_name =~ /m[sy]sql/i
      change_column :page_parts, :content, :text, :limit => 1048575
    end
  end

  def self.down
    if ActiveRecord::Base.connection.adapter_name =~ /m[sy]sql/i
      change_column :page_parts, :content, :text
    end
  end
end
