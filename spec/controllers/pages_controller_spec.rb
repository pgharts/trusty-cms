require 'spec_helper'

describe Admin::PagesController, type: :controller do
  routes { TrustyCms::Application.routes }

  let(:admin) { create(:user, first_name: 'Ada', last_name: 'Admin', email: 'admin@example.com', admin: true) }
  let!(:home) { FactoryBot.create(:home, title: 'Home') }

  describe 'authentication' do
    it 'redirects an unauthenticated user away from new' do
      get :new
      expect(response).to have_http_status(:found)
      expect(response.location).not_to include('/admin/pages/new')
    end
  end

  context 'as a signed-in admin' do
    before { sign_in(admin) }

    describe 'GET new' do
      it 'renders the new page form' do
        get :new
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'POST create' do
      let(:valid_params) do
        { page: { title: 'New Page', slug: 'new-page', breadcrumb: 'New',
                  status_id: Status[:draft].id, parent_id: home.id } }
      end

      it 'creates the page and redirects' do
        expect { post :create, params: valid_params }.to change(Page, :count).by(1)
        expect(response).to have_http_status(:found)
      end

      it 'records the current user as creator' do
        post :create, params: valid_params
        expect(Page.find_by(slug: 'new-page').created_by_id).to eq(admin.id)
      end

      it 're-renders on validation error without creating a page' do
        bad = { page: { title: '', slug: 'x', breadcrumb: '', status_id: Status[:draft].id, parent_id: home.id } }
        expect { post :create, params: bad }.not_to change(Page, :count)
        expect(flash[:error]).to be_present
      end
    end

    describe 'PATCH update' do
      let(:page) { FactoryBot.create(:page, title: 'Old', slug: 'old', breadcrumb: 'Old', parent: home, status_id: Status[:published].id) }

      it 'updates the page and redirects' do
        patch :update, params: { id: page.id, page: { title: 'New Title' } }
        expect(response).to have_http_status(:found)
        expect(page.reload.title).to eq('New Title')
      end

      it 'records the current user as editor' do
        patch :update, params: { id: page.id, page: { title: 'Edited' } }
        expect(page.reload.updated_by_id).to eq(admin.id)
      end
    end

    describe 'DELETE destroy' do
      it 'removes the page' do
        page = FactoryBot.create(:page, title: 'Doomed', slug: 'doomed', breadcrumb: 'Doomed', parent: home, status_id: Status[:published].id)
        expect { delete :destroy, params: { id: page.id } }.to change(Page, :count).by(-1)
      end
    end
  end
end

# Regression guard for the "logged out when saving a page" report: a page save
# must not invalidate the session or mutate the current user's credentials.
describe 'Saving a page keeps the user authenticated', type: :request do
  it 'preserves the session and the user record across a page save' do
    admin = FactoryBot.create(:user, first_name: 'Ada', last_name: 'Admin', email: 'admin@example.com', admin: true)
    sign_in admin
    home = FactoryBot.create(:home, title: 'Home')
    page = FactoryBot.create(:page, title: 'P', slug: 'p', breadcrumb: 'P', parent: home, status_id: Status[:published].id)

    password_before = admin.reload.encrypted_password
    id_before = admin.id

    patch "/admin/pages/#{page.id}", params: { page: { title: 'Updated' } }

    expect(response).to have_http_status(:found)
    expect(response.location).not_to match(/sign_in|login/)
    admin.reload
    expect(admin.encrypted_password).to eq(password_before)
    expect(admin.id).to eq(id_before)
  end
end
