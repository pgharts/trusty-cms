require 'uri'

module TrustyCmsClippedExtension

  module Cloud
    mattr_accessor :host_provider

    def self.credentials
      service = ActiveStorage::Blob.service
      return {} unless service.respond_to?(:config)

      service.config
    end

    def self.host
      if host_provider
        host_provider.call
      elsif defined?(TrustyCms::Config)
        TrustyCms::Config['assets.cdn.host']
      end
    end

    def self.rewrite_url(url)
      return url unless url.present?
      configured_host = host
      return url if configured_host.blank?

      uri = URI.parse(url)
      return url unless uri.is_a?(URI::HTTP)

      host_uri = URI.parse(configured_host.to_s.match?(/\Ahttps?:\/\//) ? configured_host.to_s : "https://#{configured_host}")
      uri.scheme = host_uri.scheme if host_uri.scheme
      uri.host = host_uri.host if host_uri.host
      uri.port = host_uri.port if host_uri.port

      if host_uri.path.present? && host_uri.path != '/'
        uri.path = File.join(host_uri.path, uri.path.sub(%r{\A/}, ''))
      end

      uri.to_s
    rescue URI::InvalidURIError
      url
    end
  end

end
