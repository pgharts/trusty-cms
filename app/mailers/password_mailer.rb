class PasswordMailer < ApplicationMailer

  default :from => ENV['ORG_FROM_EMAIL'] ||= "admin@trustycms.com"

  def password_reset(user)
    @user = user
    mail :to => user.email, :subject => "Password Reset for TrustyCMS"
  end

end
