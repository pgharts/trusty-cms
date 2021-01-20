class Admin::UsersController < Admin::ResourceController
  paginate_models
  only_allow_access_to :index, :show, :new, :create, :edit, :update, :remove, :destroy,
                       when: :admin,
                       denied_url: { controller: 'pages', action: 'index' },
                       denied_message: 'You must have administrative privileges to perform this action.'

  before_action :ensure_deletable, only: %i[remove destroy]

  def show
    redirect_to edit_admin_user_path(params[:id])
  end

  def create
    user = User.new(user_params)
    if user.save
      flash[:notice] = 'User was created.'
      redirect_to admin_users_path
    else
      flash[:error] = 'There was an error saving the user. Please try again.'
      render :new
    end
  end

  def update
    user_params = params[model_symbol].permit!
    if user_params && user_params['admin'] == false && model == current_user
      user_params.delete('admin')
      announce_cannot_remove_self_from_admin_role
    end
    model.skip_password_validation = true unless user_params[:password_confirmation].present?
    if model.update(user_params)
      response_for :update
    else
      flash[:error] = 'There was an error saving the user. Please try again.'
      render :edit
    end
  end

  def ensure_deletable
    if current_user.id.to_s == params[:id].to_s
      announce_cannot_delete_self
      redirect_to admin_users_path
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :admin, :designer,
                                 :password, :password_confirmation, :email, :site_id, :notes)
  end

  def announce_cannot_delete_self
    flash[:error] = t('users_controller.cannot_delete_self')
  end

  def announce_cannot_remove_self_from_admin_role
    flash[:error] = 'You cannot remove yourself from the admin role.'
  end
end
