require 'rqrcode'

class Admin::TwoFactorController < ApplicationController
  before_action :authenticate_user!

  def show
    @template_name = 'show'
    current_user.otp_secret ||= User.generate_otp_secret
    current_user.save!
    otp_uri = current_user.otp_provisioning_uri(current_user.email, issuer: "YourAppName")
    qr = RQRCode::QRCode.new(otp_uri)
    @qr_png_data = qr.as_png(size: 200).to_data_url
  end

  def verify
    if current_user.validate_and_consume_otp!(params[:otp_attempt])
      current_user.update!(otp_required_for_login: true)
      redirect_to root_path, notice: "Two-factor authentication enabled"
    else
      flash[:alert] = "Invalid 2FA code"
      redirect_to two_factor_path
    end
  end
end
