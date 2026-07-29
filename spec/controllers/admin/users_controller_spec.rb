require 'spec_helper'

# Exercises Admin::UsersController, which layers admin-only authorization and
# several custom overrides (create/update/destroy/disable_2fa, plus the
# self-protection guards) on top of ResourceController. Devise/2FA touch points
# make this a useful regression net for a Rails/Ruby upgrade.
RSpec.describe Admin::UsersController, type: :controller do
  routes { TrustyCms::Application.routes }

  let(:admin) { create(:admin) }

  before do
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_user).and_return(admin)
  end

  def valid_user_params(overrides = {})
    {
      first_name: 'New',
      last_name: 'Person',
      email: 'newperson@example.com',
      password: 'ComplexPass1!',
      password_confirmation: 'ComplexPass1!',
    }.merge(overrides)
  end

  describe 'GET #index' do
    it 'succeeds for an admin' do
      get :index
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET #new' do
    it 'succeeds' do
      get :new
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET #show' do
    it 'redirects to the edit page' do
      user = create(:user, email: 'showme@example.com')
      get :show, params: { id: user.id }
      expect(response).to redirect_to(edit_admin_user_path(user.id))
    end
  end

  describe 'POST #create' do
    it 'creates a user and redirects with a notice' do
      expect {
        post :create, params: { user: valid_user_params }
      }.to change(User, :count).by(1)

      expect(response).to redirect_to(admin_users_path)
      expect(flash[:notice]).to eq('User was created.')
    end

    it 're-renders new with an error when the user is invalid' do
      expect {
        post :create, params: { user: valid_user_params(email: '') }
      }.not_to change(User, :count)

      expect(flash[:error]).to match(/error saving the user/)
    end
  end

  describe 'PUT #update' do
    it 'updates an existing user and redirects' do
      user = create(:user, email: 'editme@example.com')

      put :update, params: { id: user.id, user: { first_name: 'Renamed' } }

      expect(response).to be_redirect
      expect(user.reload.first_name).to eq('Renamed')
    end

    # NOTE: latent bug — the guard compares `user_params['admin'] == false`, but
    # over a real HTTP request the checkbox param arrives as the string 'false',
    # which is != false. So through the normal request path an admin CAN demote
    # themselves and no warning is shown. Characterizing current behavior;
    # revisit if the guard is ever fixed to coerce the param.
    it 'does NOT block self-demotion when admin arrives as the string "false" (bug)' do
      put :update, params: { id: admin.id, user: { admin: 'false' } }

      expect(admin.reload.admin).to be(false)
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys another user' do
      user = create(:user, email: 'goner@example.com')

      expect {
        delete :destroy, params: { id: user.id }
      }.to change(User, :count).by(-1)
    end

    it 'refuses to let a user delete themselves' do
      expect {
        delete :destroy, params: { id: admin.id }
      }.not_to change(User, :count)

      expect(response).to redirect_to(admin_users_path)
      expect(flash[:error]).to be_present
    end
  end

  describe 'PATCH #disable_2fa' do
    it 'clears the OTP settings and redirects' do
      user = create(:user, email: '2fa@example.com', otp_required_for_login: true)

      patch :disable_2fa, params: { id: user.id }

      user.reload
      expect(user.otp_required_for_login).to be(false)
      expect(user.otp_secret).to be_nil
      expect(response).to redirect_to(admin_users_path)
    end
  end

  describe 'authorization' do
    it 'denies a non-admin user' do
      allow(controller).to receive(:current_user).and_return(create(:non_admin, email: 'plain@example.com'))

      get :index

      expect(response).to be_redirect
      expect(flash[:error]).to be_present
    end
  end
end
