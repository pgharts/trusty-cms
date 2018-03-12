module TrustyCmsClippedExtension

  module Cloud

    def self.credentials
      case TrustyCms.config["paperclip.fog.provider"]
      when "AWS"
        {
          :provider => "AWS",
          :aws_access_key_id => TrustyCms.config["paperclip.s3.key"],
          :aws_secret_access_key => TrustyCms.config["paperclip.s3.secret"],
          :region => TrustyCms.config["paperclip.s3.region"],
        }
      when "Google"
        {
          :provider => "Google",
          :rackspace_username => TrustyCms.config["paperclip.google_storage.access_key_id"],
          :rackspace_api_key  => TrustyCms.config["paperclip.google_storage.secret_access_key"]
        }
      when "Rackspace"
        {
          :provider => "Rackspace",
          :rackspace_username => TrustyCms.config["paperclip.rackspace.username"],
          :rackspace_api_key  => TrustyCms.config["paperclip.rackspace.api_key"]
        }
      end
    end

    def self.host
      return TrustyCms.config["paperclip.fog.host"] if TrustyCms.config["paperclip.fog.host"]
      case TrustyCms.config["paperclip.fog.provider"]
      when "AWS"
        "http://#{TrustyCms.config['paperclip.fog.directory']}.s3.amazonaws.com"
      else
        nil
      end
    end

  end

end
