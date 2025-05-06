require 'rqrcode'

class Admin::SecurityController < ApplicationController
  before_action :authenticate_user!
  before_action :initialize_variables

  def show
    set_standard_body_style

    current_user.otp_secret ||= User.generate_otp_secret
    current_user.save!

    @two_factor_enabled = current_user.otp_required_for_login

    unless @two_factor_enabled
      otp_uri = current_user.otp_provisioning_uri(current_user.email, issuer: "YourAppName")
      qr = RQRCode::QRCode.new(otp_uri)
      @qr_png_data = qr.as_png(size: 200).to_data_url
    end

    render :edit
  end

  def edit
    render
  end

  def update
    if @user.update(security_params)
      redirect_to admin_configuration_path
    else
      flash[:error] = t('preferences_controller.error_updating')
      render :edit
    end
  end

  def verify_two_factor
    if current_user.validate_and_consume_otp!(params[:otp_attempt])
      current_user.update!(otp_required_for_login: true)
      redirect_to admin_security_path, notice: "Two-Factor Authentication Enabled"
    else
      flash[:error] = "Invalid 2FA code"
      redirect_to admin_security_path, error: "Invalid 2FA code"
    end
  end

  def disable_two_factor
    if current_user.update!(otp_required_for_login: false)
      redirect_to admin_security_path, notice: "Two-Factor Authentication Disabled"
    else
      flash[:error] = "Error Disabling Two-Factor Authentication"
      redirect_to admin_security_path
    end
  end

  private

  def initialize_variables
    @user            = current_user
    @controller_name = 'user'
    @template_name   = 'security'
  end

  def security_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
