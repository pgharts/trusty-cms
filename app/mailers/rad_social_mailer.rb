class RadSocialMailer < ApplicationMailer
  include Roadie::Rails::Automatic

  def social_mail options
    from_address = Mail::Address.new options[:from] # ex: "john@example.com"
    from_address.display_name = options[:from_name] # ex: "John Doe"

    @from_name = from_address.display_name
    @from_email = from_address
    @message = options[:message]
    @actual_from = ENV['RAD_SOCIAL_FROM_EMAIL']
    @actual_from = from_address if @actual_from.nil?

    mail({
      to: options[:to],
      from: @actual_from,
      reply_to: @from_email,
      subject: options[:subject],
      text: @message,
      content_type: "text/html"
     })
  end
end
