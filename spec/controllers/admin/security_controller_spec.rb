require 'spec_helper'

# Exercises Admin::SecurityController — password changes and TOTP two-factor
# enable/disable/verify for the current user. Touches devise-two-factor and QR
# provisioning, both plausible upgrade casualties.
RSpec.describe Admin::SecurityController, type: :controller do
  routes { TrustyCms::Application.routes }

  let(:user) { create(:admin) }

  before do
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
    # sign_out/sign_in need Warden wiring we don't set up here; the auth side
    # effect isn't what these specs are checking.
    allow(controller).to receive(:sign_out)
  end

  describe 'GET #show' do
    it 'generates an OTP secret and QR provisioning data' do
      expect(user.otp_secret).to be_blank

      get :show

      expect(response).to have_http_status(:ok)
      expect(user.reload.otp_secret).to be_present
      expect(controller.instance_variable_get(:@qr_png_data)).to start_with('data:image/png')
    end
  end

  describe 'GET #edit' do
    it 'succeeds' do
      get :edit
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PUT #update' do
    it 'updates the password, signs out, and redirects to sign-in' do
      put :update, params: { user: { password: 'NewComplex1!', password_confirmation: 'NewComplex1!' } }

      expect(controller).to have_received(:sign_out).with(user)
      expect(response).to redirect_to(new_user_session_path)
    end

    it 're-renders edit when the password change is invalid' do
      put :update, params: { user: { password: 'x', password_confirmation: 'y' } }

      expect(flash[:error]).to be_present
    end
  end

  describe 'POST #verify_two_factor' do
    it 'enables 2FA when the OTP is valid' do
      allow(user).to receive(:validate_and_consume_otp!).with('123456').and_return(true)

      post :verify_two_factor, params: { otp_attempt: '123456' }

      expect(user.reload.otp_required_for_login).to be(true)
      expect(response).to redirect_to(admin_security_path)
    end

    it 'reports an error when the OTP is invalid' do
      allow(user).to receive(:validate_and_consume_otp!).and_return(false)

      post :verify_two_factor, params: { otp_attempt: 'bad' }

      expect(flash[:error]).to be_present
      expect(response).to redirect_to(admin_security_path)
    end
  end

  describe 'POST #disable_two_factor' do
    it 'clears the OTP settings and redirects' do
      user.update!(otp_required_for_login: true, otp_secret: User.generate_otp_secret)

      post :disable_two_factor

      user.reload
      expect(user.otp_required_for_login).to be(false)
      expect(user.otp_secret).to be_nil
      expect(response).to redirect_to(admin_security_path)
    end
  end
end
