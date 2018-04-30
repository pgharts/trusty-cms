class UpdateConfiguration < ActiveRecord::Migration[5.2]
  def self.up
    if TrustyCms.config.table_exists?

      puts "Importing paperclip configuration"
      %w{url path skip_filetype_validation storage}.select{|k| !!TrustyCms.config["assets.#{k}"] }.each do |k|
        begin
          TrustyCms.config["paperclip.#{k}"] = TrustyCms.config["assets.#{k}"]
        rescue ActiveRecord::RecordInvalid => e
          print "Oops! There was trouble setting #{k} to '#{TrustyCms.config["assets.#{k}"]}'"
          print "\nSetting it to 'fog'. Please see the clipped extension README for more details."
          TrustyCms.config["paperclip.#{k}"] = 'fog'
        end
      end

      puts "Importing s3 storage configuration"
      %w{bucket key secret host_alias}.select{|k| !!TrustyCms.config["assets.s3.#{k}"] }.each do |k|
        TrustyCms.config["paperclip.s3.#{k}"] = TrustyCms.config["assets.s3.#{k}"]
      end

      puts "Importing thumbnail configuration"
      if thumbnails = TrustyCms.config["assets.additional_thumbnails"]
        old_styles = thumbnails.to_s.gsub(' ','').split(',').collect{|s| s.split('=')}.inject({}) {|ha, (k, v)| ha[k.to_sym] = v; ha}
        new_styles = old_styles.map {|k,v| "#{k}:size=#{v}"}
        TrustyCms.config["assets.thumbnails.image"] = new_styles.join("|")
        TrustyCms.config["assets.thumbnails.video"] = new_styles.map{|s| "#{s},format=jpg"}.join("|")
        TrustyCms.config["assets.thumbnails.pdf"] = new_styles.map{|s| "#{s},format=jpg"}.join("|")
      end
    end
  end

  def self.down
  end
end
