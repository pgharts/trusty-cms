class SocialMailerController < ApplicationController
  include ShareLayouts::Controllers::ActionController
  trusty_layout 'default', { only: :create_social_mail }
  #  no_login_required
  skip_before_action :authenticate_user!

  def create_social_mail
    mailer_options = {
      to: params[:to],
      from: params[:from],
      from_name: params[:from_name],
      message: params[:message],
      subject: params[:subject],
    }
  end

  def social_mail_form
    render template: 'rad_social_mailer/social_mail_form',
           layout: false,
           locals: {
             email_message: params[:email_message],
             email_subject: params[:email_subject],
             email_action_url: params[:email_action_url],
           }
  end
end
