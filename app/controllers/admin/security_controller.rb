require 'rqrcode'

class Admin::SecurityController < ApplicationController
  before_action :authenticate_user!
  before_action :initialize_variables
  before_action :initialize_two_factor_variables, only: [:show, :edit, :update]

  def show
    set_standard_body_style
    ensure_user_has_otp_secret!
    render :edit
  end

  def edit
    render
  end

  def update
    if @user.update(security_params)
      sign_out(@user)
      redirect_to new_user_session_path, notice: t('security_controller.password_updated')
    else
      flash[:error] = t('security_controller.error_updating_password')
      render :edit
    end
  end

  def verify_two_factor
    if current_user.validate_and_consume_otp!(params[:otp_attempt])
      current_user.update!(otp_required_for_login: true)
      redirect_to admin_security_path, notice: t('security_controller.two_factor_enabled')
    else
      flash[:error] = t('security_controller.two_factor_invalid_code')
      redirect_to admin_security_path
    end
  end

  def disable_two_factor
    if current_user.update!(otp_required_for_login: false)
      redirect_to admin_security_path, notice: t('security_controller.two_factor_disabled')
    else
      flash[:error] = t('security_controller.two_factor_disabled_error')
      redirect_to admin_security_path
    end
  end

  private

  def initialize_variables
    @user            = current_user
    @controller_name = 'user'
    @template_name   = 'security'
  end

  def ensure_user_has_otp_secret!
    return if current_user.otp_secret.present?
  
    current_user.update!(otp_secret: User.generate_otp_secret)
  end

  def initialize_two_factor_variables
    @two_factor_enabled = current_user.otp_required_for_login

    unless @two_factor_enabled
      otp_uri = current_user.otp_provisioning_uri(current_user.email, issuer: "TrustyCMS")
      qr = RQRCode::QRCode.new(otp_uri)
      @qr_png_data = qr.as_png(size: 200).to_data_url
    end
  end

  def security_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
