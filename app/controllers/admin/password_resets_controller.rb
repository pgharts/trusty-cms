class Admin::PasswordResetsController < ApplicationController
  #  no_login_required
  skip_before_action :authenticate_user!
  
  def create
    user = User.find_by_email(params[:email])
    user.send_password_reset if user
    redirect_to welcome_path, :notice => "If the e-mail address you entered is associated with a customer account in our records, you will receive an e-mail from us with instructions for resetting your password.
    If you don't receive this e-mail, please check your junk mail folder or speak with your TrustyCMS administrator."
  end

  def edit
    @user = User.find_by_password_reset_token!(params[:id])
  end

  def update
    @user = User.find_by_password_reset_token!(params[:id])
    if @user.password_reset_sent_at < 2.hours.ago
      redirect_to new_password_reset_path, :alert => "Password reset has expired."
    elsif @user.update_attributes(password_params)
      redirect_to welcome_url, :notice => "Password has been reset!"
    else
      render :edit
    end
  end

private

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
