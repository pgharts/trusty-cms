TrustyCms.config do |config|

  # Uncomment and change the settings below to customize the Clipped extension

  # The default settings
  # config["assets.max_asset_size"] = 10 # megabytes
  # config["assets.max_video_size"] = 50 # megabytes
  # config["assets.display_size"] = "normal"
  # config["assets.insertion_size"] = "normal"
  # config["assets.create_image_thumbnails?"] = true
  # config["assets.create_video_thumbnails?"] = true
  # config["assets.create_pdf_thumbnails?"] = true
  # Check http://www.imagemagick.org/script/command-line-processing.php#geometry
  # for more details on ImageMagick settings for thumbnail generation
  # config["assets.thumbnails.image"] = "normal:size=640x640>|small:size=320x320>"
  # config["assets.thumbnails.video"] = "normal:size=640x640>,format=jpg|small:size=320x320>,format=jpg"
  # config["assets.thumbnails.pdf"] = "normal:size=640x640>,format=jpg|small:size=320x320>,format=jpg"

  # ActiveStorage configuration is handled in config/storage.yml and
  # config.active_storage.service (per environment). For S3 or other
  # cloud providers, configure the appropriate ActiveStorage service.
  #
  # Optional CDN host override for ActiveStorage URLs:
  # config["assets.cdn.host"] = "https://assets.example.com"
  #
  # Or provide a dynamic host in an initializer:
  # TrustyCmsClippedExtension::Cloud.host_provider = -> { AssetBucket.current&.asset_host }

end
