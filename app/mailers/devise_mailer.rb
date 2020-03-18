class DeviseMailer < Devise::Mailer

  def reset_password_instructions(record, token, opts={})
    mail = super
    mail.subject = "Reset Password for TrustyCMS for ${record.first_name}"
    mail
  end  
end