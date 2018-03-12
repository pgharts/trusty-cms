require 'multi_site/engine'
require 'clipped/engine'

TrustyCms.config do |config|
  config.define 'admin.title', :default => "TrustyCms CMS"
  config.define 'dev.host'
  config.define 'local.timezone', :allow_change => true, :select_from => lambda { ActiveSupport::TimeZone::MAPPING.keys.sort }
  config.define 'defaults.locale', :select_from => lambda { TrustyCms::AvailableLocales.locales }, :allow_blank => true
  config.define 'defaults.page.parts', :default => "Body,Extended"
  config.define 'defaults.page.status', :select_from => lambda { Status.selectable_values }, :allow_blank => false, :default => "Draft"
  config.define 'defaults.page.filter', :select_from => lambda { TextFilter.descendants.map { |s| s.filter_name }.sort }, :allow_blank => true
  config.define 'defaults.page.fields'
  config.define 'pagination.param_name', :default => 'page'
  config.define 'pagination.per_page_param_name', :default => 'per_page'
  config.define 'admin.pagination.per_page', :type => :integer, :default => 50
  config.define 'site.title', :default => "Your site title", :allow_blank => false
  config.define 'site.host', :default => "www.example.com", :allow_blank => false
  config.define 'user.allow_password_reset?', :default => true
  config.define 'session_timeout', :default => 2.weeks
  require 'multi_site/scoped_validation'
end

TrustyCms.config do |config|
  config.namespace 'paperclip' do |pc|
    pc.define 'url',                      :default => '/system/:attachment/:id/:style/:basename:no_original_style.:extension', :allow_change => true
    pc.define 'path',                     :default => ':rails_root/public/system/:attachment/:id/:style/:basename:no_original_style.:extension', :allow_change => true
    pc.define 'skip_filetype_validation', :default => true, :type => :boolean
    pc.define 'storage', :default       => 'filesystem',
                         :select_from   => {
                           'File System'            => 'filesystem',
                           'Amazon S3'              => 'fog',
                           'Google Storage'         => 'fog',
                           'Rackspace Cloud Files'  => 'fog'
                         },
                         :allow_blank   => false,
                         :allow_display => false

    pc.namespace 'fog' do |fog|
      fog.define 'provider', :select_from => {
                               'Amazon S3'              => 'AWS',
                               'Google Storage'         => 'Google',
                               'Rackspace Cloud Files'  => 'Rackspace'
                             }
      fog.define 'directory'
      fog.define 'public?', :default => true
      fog.define 'host'
    end

    pc.namespace 'google_storage' do |gs|
      gs.define 'access_key_id'
      gs.define 'secret_access_key'
    end

    pc.namespace 'rackspace' do |rs|
      rs.define 'username'
      rs.define 'api_key'
    end

    pc.namespace 's3' do |s3|
      s3.define 'key'
      s3.define 'secret'
      s3.define 'region', :select_from => {
                            'Asia North East' => 'ap-northeast-1',
                            'Asia South East' => 'ap-southeast-1',
                            'EU West' => 'eu-west-1',
                            'US East' => 'us-east-1',
                            'US West' => 'us-west-1'
                          }
    end
  end

  config.namespace 'assets', :allow_display => false do |assets|
    assets.define 'create_image_thumbnails?', :default => 'true'
    assets.define 'create_video_thumbnails?', :default => 'true'
    assets.define 'create_pdf_thumbnails?', :default => 'true'

    assets.namespace 'thumbnails' do |thumbs| # NB :icon and :thumbnail are already defined as fixed formats for use in the admin interface and can't be changed
      thumbs.define 'image', :default => 'normal:size=640x640>|small:size=320x320>'
      thumbs.define 'video', :default => 'normal:size=640x640>,format=jpg|small:size=320x320>,format=jpg'
      thumbs.define 'pdf', :default => 'normal:size=640x640>,format=jpg|small:size=320x320>,format=jpg'
    end

    assets.define 'max_asset_size', :default => 5, :type => :integer, :units => 'MB'
    assets.define 'display_size', :default => 'normal', :allow_blank => true
    assets.define 'insertion_size', :default => 'normal', :allow_blank => true
  end
end

if TrustyCms.config_definitions['defaults.snippet.filter'].nil?
  TrustyCms.config.define 'defaults.snippet.filter', :select_from => lambda { TextFilter.descendants.map { |s| s.filter_name }.sort }, :allow_blank => true
end

Admin::LayoutsController.send :helper, MultiSite::SiteChooserHelper
Admin::SnippetsController.send :helper, MultiSite::SiteChooserHelper
