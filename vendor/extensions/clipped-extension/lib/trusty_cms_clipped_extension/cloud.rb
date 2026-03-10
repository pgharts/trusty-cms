module TrustyCmsClippedExtension

  module Cloud

    def self.credentials
      service = ActiveStorage::Blob.service
      return {} unless service.respond_to?(:config)

      service.config
    end

    def self.host
      nil
    end

  end

end
