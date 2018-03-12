TrustyCms.config do |config|

  # Uncomment and change the settings below to customize the Clipped extension

  # The default settings
  # config["paperclip.url"] = "/system/:attachment/:id/:style/:basename:no_original_style.:extension"
  # config["paperclip.path"] = ":rails_root/public/system/:attachment/:id/:style/:basename:no_original_style.:extension"
  # config["paperclip.storage"] = "filesystem"
  # config["paperclip.skip_filetype_validation"] = true
  # config["assets.max_asset_size"] = 5 # megabytes
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

  # An example of using Amazon S3
  # add `gem "fog", "~> 1.0"` to your Gemfile and run `bundle install`
  # config["paperclip.storage"] = "fog"
  # config["paperclip.path"] = ":attachment/:id/:style/:basename:no_original_style.:extension"
  # config["paperclip.fog.provider"] = "AWS"
  # config["paperclip.fog.directory"] = "bucket-name"
  # config["paperclip.s3.key"] = "S3_KEY"
  # config["paperclip.s3.secret"] = "S3_SECRET"
  # optionally use a custom domain name; requires a CNAME DNS record
  # config["paperclip.fog.host"] = "http://assets.example.com"
  # optionally set the S3 region of your bucket; defaults to US East
  # Asia North East => ap-northeast-1
  # Asia South East => ap-southeast-1
  # EU West => eu-west-1
  # US East => us-east-1
  # US West => us-west-1
  # config["paperclip.s3.region"] = "us-east-1"

  # An example of using Rackspace Cloud Files
  # add `gem "fog", "~> 1.0"` to your Gemfile and run `bundle install`
  # config["paperclip.storage"] = "fog"
  # config["paperclip.path"] = ":attachment/:id/:style/:basename:no_original_style.:extension"
  # config["paperclip.fog.provider"] = "Rackspace"
  # config["paperclip.fog.directory"] = "container-name"
  # config["paperclip.rackspace.username"] = "RACKSPACE_USERNAME"
  # config["paperclip.rackspace.api_key"] = "RACKSPACE_API_KEY"
  # paperclip.fog.host is your Cloud Files CDN URL
  # config["paperclip.fog.host"] = "http://a.b.c.rackcdn.com"
  # optionally use a custom domain name; requires a CNAME DNS record
  # config["paperclip.fog.host"] = "http://assets.example.com"

end
