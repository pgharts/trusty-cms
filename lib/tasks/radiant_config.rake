require 'trusty_cms/task_support'
namespace :trusty_cms do
  namespace :config do
    desc 'Export TrustyCms::Config to Rails.root/config/trusty_config.yml. Specify a path with TRUSTY_CONFIG_PATH - defaults to Rails.root/config/trusty_config.yml'
    task export: :environment do
      config_path = ENV['TRUSTY_CONFIG_PATH'] || "#{Rails.root}/config/trusty_config.yml"
      clear = ENV.fetch('CLEAR_CONFIG', nil)
      TrustyCms::TaskSupport.config_export(config_path)
    end

    desc 'Import TrustyCms::Config from Rails.root/config/trusty_config.yml. Specify a path with TRUSTY_CONFIG_PATH - defaults to Rails.root/config/trusty_config.yml Set CLEAR_CONFIG=true to delete all existing settings before import'
    task import: :environment do
      config_path = ENV['TRUSTY_CONFIG_PATH'] || "#{Rails.root}/config/trusty_config.yml"
      clear = ENV.fetch('CLEAR_CONFIG', nil)
      TrustyCms::TaskSupport.config_import(config_path, clear)
    end
  end
end
