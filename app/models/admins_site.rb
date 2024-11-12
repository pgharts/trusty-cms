class AdminsSite < ActiveRecord::Base
  self.table_name = 'admins_sites'

  belongs_to :admin, class_name: 'User'
  belongs_to :site

  attr_accessor :admin_id, :site_id
end