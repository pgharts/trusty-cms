# This migration comes from trusty_cms_engine (originally 14)
class RenameConfigDefaultPartsKey < ActiveRecord::Migration[5.2]

  def self.up
    rename_config_key 'default.parts', 'defaults.page.parts'
  end

  def self.down
    rename_config_key 'defaults.page.parts', 'default.parts'
  end

  def self.rename_config_key(from, to)
    return unless setting = TrustyCms::Config.find_by_key(from)
    setting.key = to
    setting.save!
  end

end
