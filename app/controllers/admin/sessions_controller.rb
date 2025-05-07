class Admin::SessionsController < Devise::SessionsController
  def new
    super
  end

  def create
    user = User.find_by(email: params[:user][:email])

    if user&.valid_password?(params[:user][:password])
      if user.otp_required_for_login
        session[:pre_2fa_user_id] = user.id
        session[:pre_2fa_started_at] = Time.current.to_i
        redirect_to admin_two_factor_path
      else
        sign_in(:user, user)
        redirect_to after_sign_in_path_for(user)
      end
    else
      self.resource = resource_class.new(sign_in_params)
      clean_up_passwords(resource)
      flash.now[:alert] = "Invalid email or password."
      render :new
    end
  end
end
