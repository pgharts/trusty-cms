module RadSocialHelper

  def rad_test_method
    "SURPRISE SURPRISE SURPRISE"
  end

  def rad_share_widget(options)
    url = options[:url].nil? ? request.url : options[:url]
    message = options[:message].nil? ? "Check out #{options[:title]}." : options[:message]
    email_subject = options[:email_subject].nil? ? options[:title] : options[:email_subject]
    email_message = options[:email_message].nil? ? "I thought you might be interested in this: #{url}" : "#{options[:email_message]} #{url}"
    email_action_url = options[:email_action_url].nil? ? "/rad_social/mail" : options[:email_action_url]

    render :partial => "widget/horizontal_widget",
                             :locals => { :url => url,
                                          :message => message,
                                          :email_subject => email_subject,
                                          :email_message => email_message,
                                          :email_action_url => email_action_url
                             }
  end

end