class Admin::SessionsController < Devise::SessionsController
  def create
    user = find_user

    if authenticated?(user)
      handle_successful_authentication(user)
    else
      handle_failed_authentication
    end
  end

  private

  def find_user
    User.find_by(email: params[:user][:email])
  end

  def authenticated?(user)
    user&.valid_password?(params[:user][:password])
  end

  def handle_successful_authentication(user)
    if user.otp_required_for_login
      start_two_factor_session(user)
      redirect_to admin_two_factor_path
    else
      sign_in(:user, user)
      redirect_to after_sign_in_path_for(user)
    end
  end

  def handle_failed_authentication
    self.resource = resource_class.new(sign_in_params)
    clean_up_passwords(resource)
    flash.now[:alert] = t('invalid_email_or_password')
    render :new
  end

  def start_two_factor_session(user)
    session[:pre_2fa_user_id] = user.id
    session[:pre_2fa_started_at] = Time.current.to_i
  end
end
