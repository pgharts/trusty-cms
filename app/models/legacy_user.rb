class LegacyUser < ActiveRecord::Base
  self.table_name = 'users'

  # this is a legacy class
  # this table formally held user information for when TrustyCMS had a handwritten authentication system
end
