require 'spec_helper'

# Exercises Admin::SessionsController#create — the custom login flow that
# branches into the two-factor handoff for OTP-enabled users. Overriding a
# Devise controller is exactly the sort of thing that can break across a Devise
# major, so pin the three branches (2FA, plain sign-in, bad credentials).
RSpec.describe Admin::SessionsController, type: :controller do
  routes { TrustyCms::Application.routes }
  include Devise::Test::ControllerHelpers

  let(:password) { 'ComplexPass1!' }

  before do
    request.env['devise.mapping'] = Devise.mappings[:user]
    # sign_in needs Warden wiring that isn't the focus here.
    allow(controller).to receive(:sign_in)
  end

  describe 'POST #create' do
    it 'signs in a valid non-2FA user and redirects' do
      user = create(:admin, password: password)

      post :create, params: { user: { email: user.email, password: password } }

      expect(controller).to have_received(:sign_in).with(:user, user)
      expect(response).to redirect_to(admin_pages_path)
    end

    it 'starts the 2FA handoff for an OTP-enabled user' do
      user = create(:admin, password: password, otp_required_for_login: true)

      post :create, params: { user: { email: user.email, password: password } }

      expect(response).to redirect_to(admin_two_factor_path)
      expect(session[:pre_2fa_user_id]).to eq(user.id)
      expect(session[:pre_2fa_started_at]).to be_present
      expect(controller).not_to have_received(:sign_in)
    end

    it 're-renders the sign-in form on bad credentials' do
      user = create(:admin, password: password)

      post :create, params: { user: { email: user.email, password: 'wrong' } }

      expect(controller).not_to have_received(:sign_in)
      expect(flash.now[:alert]).to be_present
    end

    it 're-renders the sign-in form for an unknown email' do
      post :create, params: { user: { email: 'nobody@example.com', password: password } }

      expect(controller).not_to have_received(:sign_in)
      expect(flash.now[:alert]).to be_present
    end
  end
end
