class AdminsSite < ActiveRecord::Base
  self.table_name = 'admins_sites'

  belongs_to :admin, class_name: 'User'
  belongs_to :site
end