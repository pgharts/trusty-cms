class Admin::PreferencesController < ApplicationController
  before_action :initialize_variables

  def show
    set_standard_body_style
    render :edit
  end

  def edit
    render
  end

  def update
    if @user.update_attributes(params[:user])
      redirect_to admin_configuration_path
    else
      flash[:error] = t('preferences_controller.error_updating')
      render :edit
    end
  end

  private

  def initialize_variables
    @user            = current_user
    @controller_name = 'user'
    @template_name   = 'preferences'
  end
end
