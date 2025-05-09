class Admin::TwoFactorController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :load_pre_2fa_user

  MAX_2FA_SESSION_DURATION = 5.minutes.freeze

  def show; end

  def create
    if @user.validate_and_consume_otp!(params[:otp_attempt])
      session.delete(:pre_2fa_user_id)
      session.delete(:pre_2fa_started_at)
      sign_in(:user, @user)
      redirect_to after_sign_in_path_for(@user)
    else
      reset_session
      redirect_to new_user_session_path, alert: t('two_factor_controller.invalid_code')
    end
  end

  private

  def load_pre_2fa_user
    if current_user
      redirect_to after_sign_in_path_for(current_user) and return
    end

    @user = User.find_by(id: session[:pre_2fa_user_id])

    if !@user&.otp_required_for_login || session_expired?
      reset_session
      redirect_to new_user_session_path, alert: t('two_factor_controller.session_expired')
    end
  end

  def session_expired?
    started_at = session[:pre_2fa_started_at]
    return true unless started_at

    Time.current.to_i - started_at > MAX_2FA_SESSION_DURATION
  end
end
