require 'spec_helper'

# Exercises Admin::TwoFactorController — the mid-login TOTP challenge. It runs
# BEFORE the user is fully signed in (authenticate_user! is skipped) and drives
# the flow off a short-lived session handoff (:pre_2fa_user_id / :started_at).
RSpec.describe Admin::TwoFactorController, type: :controller do
  routes { TrustyCms::Application.routes }
  # current_user is read via Devise even though authenticate_user! is skipped.
  include Devise::Test::ControllerHelpers

  let(:user) { create(:admin, otp_required_for_login: true) }

  # Put the user mid-2FA: pending id in the session, started just now.
  def begin_2fa!(started_at: Time.current.to_i)
    session[:pre_2fa_user_id] = user.id
    session[:pre_2fa_started_at] = started_at
  end

  before { allow(controller).to receive(:sign_in) }

  describe 'GET #show' do
    it 'renders the challenge for a user mid-2FA' do
      begin_2fa!
      get :show
      expect(response).to have_http_status(:ok)
    end

    it 'redirects to sign-in when there is no pending 2FA session' do
      get :show
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to be_present
    end

    it 'redirects to sign-in when the 2FA session has expired' do
      begin_2fa!(started_at: 10.minutes.ago.to_i)
      get :show
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe 'POST #create' do
    before { begin_2fa! }

    it 'signs the user in and clears the handoff when the code is valid' do
      allow_any_instance_of(User).to receive(:validate_and_consume_otp!).with('123456').and_return(true)

      post :create, params: { otp_attempt: '123456' }

      expect(controller).to have_received(:sign_in).with(:user, an_instance_of(User))
      expect(response).to redirect_to(admin_pages_path)
      expect(session[:pre_2fa_user_id]).to be_nil
    end

    it 'resets the session and redirects when the code is invalid' do
      allow_any_instance_of(User).to receive(:validate_and_consume_otp!).and_return(false)

      post :create, params: { otp_attempt: 'wrong' }

      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to be_present
    end
  end
end
