# This migration comes from trusty_cms_engine (originally 2)
class InsertInitialData < ActiveRecord::Migration[5.2]

  # Historical. We no longer rely on this migration to insert the initial data into
  # the database. Instead we recommend `rake db:bootstrap`.

  def self.up
  end

  def self.down
  end

end
