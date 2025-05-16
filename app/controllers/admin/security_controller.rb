require 'rqrcode'

class Admin::SecurityController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  before_action :set_template_names
  before_action :ensure_otp_secret, only: [:show, :edit]
  before_action :set_two_factor_variables, only: [:show, :edit]

  def show
    set_standard_body_style
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
    if @user.validate_and_consume_otp!(params[:otp_attempt])
      @user.update!(otp_required_for_login: true)
      redirect_to admin_security_path, notice: t('security_controller.two_factor_enabled')
    else
      flash[:error] = t('security_controller.two_factor_invalid_code')
      redirect_to admin_security_path
    end
  end

  def disable_two_factor
    if @user.update(otp_required_for_login: false, otp_secret: nil)
      redirect_to admin_security_path, notice: t('security_controller.two_factor_disabled')
    else
      flash[:error] = t('security_controller.two_factor_disabled_error')
      redirect_to admin_security_path
    end
  end

  private

  def set_user
    @user = current_user
  end

  def set_template_names
    @controller_name = 'user'
    @template_name = 'security'
  end

  def ensure_otp_secret
    return if @user.otp_secret.present?

    @user.update!(otp_secret: User.generate_otp_secret)
  end

  def set_two_factor_variables
    @two_factor_enabled = @user.otp_required_for_login

    return if @two_factor_enabled

    otp_uri = @user.otp_provisioning_uri(@user.email, issuer: 'TrustyCMS')
    qr = RQRCode::QRCode.new(otp_uri)
    @qr_png_data = qr.as_png(size: 200).to_data_url
  end

  def security_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
