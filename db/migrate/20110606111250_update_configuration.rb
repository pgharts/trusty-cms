class UpdateConfiguration < ActiveRecord::Migration[5.2]
  def self.up
    if TrustyCms.config.table_exists?

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
