require 'spec_helper'

# Exercises Admin::ConfigurationController, which batch-updates TrustyCms::Config
# entries inside a transaction and is admin-gated. Config plumbing is easy to
# break in a framework upgrade, so pin the happy path and the auth gate.
RSpec.describe Admin::ConfigurationController, type: :controller do
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
    it 'succeeds for an admin' do
      get :edit
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PUT #update' do
    it 'persists the submitted config values and redirects to show' do
      put :update, params: { trusty_config: { 'admin.title' => 'Renamed CMS' } }

      expect(response).to redirect_to(action: :show)
      expect(TrustyCms::Config['admin.title']).to eq('Renamed CMS')
    end
  end

  describe 'authorization' do
    it 'denies a non-admin access to edit' do
      allow(controller).to receive(:current_user).and_return(create(:non_admin, email: 'plain@example.com'))

      get :edit

      expect(response).to be_redirect
      expect(flash[:error]).to be_present
    end
  end
end
