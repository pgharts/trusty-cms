class PasswordMailer < ActionMailer::Base

  def password_reset(user)
    @user = user
    mail :to => user.email, :subject => "Password Reset for TrustyCMS"
  end

end
