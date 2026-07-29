require 'spec_helper'

# Exercises Admin::PreferencesController, which lets the current user edit their
# own profile/preferences. Simple ApplicationController subclass; covers the
# show/edit render paths and the valid/invalid update branches.
RSpec.describe Admin::PreferencesController, type: :controller do
  routes { TrustyCms::Application.routes }

  let(:admin) { create(:admin) }

  before do
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_user).and_return(admin)
  end

  describe 'GET #show' do
    it 'succeeds' do
      get :show
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET #edit' do
    it 'succeeds' do
      get :edit
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PUT #update' do
    it 'updates the current user and redirects to configuration' do
      put :update, params: { user: { first_name: 'Preferred' } }

      expect(response).to redirect_to(admin_configuration_path)
      expect(admin.reload.first_name).to eq('Preferred')
    end

    it 're-renders edit with an error when the update is invalid' do
      put :update, params: { user: { email: 'not-an-email' } }

      expect(flash[:error]).to be_present
    end
  end
end
