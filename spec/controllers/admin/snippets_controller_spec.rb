require 'spec_helper'

# Exercises the full request cycle through Admin::ResourceController (the base
# for most admin CRUD): before-action chain, permitted_params, response_for
# dispatch, and the redirect/re-render paths. High blast radius for a Rails
# upgrade, so keep this green before and after the bump.
RSpec.describe Admin::SnippetsController, type: :controller do
  routes { TrustyCms::Application.routes }

  let(:user) { create(:admin) }

  before do
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe 'GET #index' do
    it 'succeeds for an authorized user' do
      create(:snippet, name: 'listed')
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

  describe 'POST #create' do
    it 'creates a snippet and redirects to the index' do
      expect {
        post :create, params: { snippet: { name: 'greeting', content: 'Hello' } }
      }.to change(Snippet, :count).by(1)

      expect(response).to be_redirect
      expect(Snippet.find_by(name: 'greeting').content).to eq('Hello')
    end

    it 'records the creating user' do
      post :create, params: { snippet: { name: 'owned', content: 'x' } }
      expect(Snippet.find_by(name: 'owned').created_by_id).to eq(user.id)
    end

    # NOTE: Admin::ResourceController defines #rescue_action, but that is a
    # Rails 2 hook the framework no longer calls, and it is not re-wired via
    # rescue_from (only Admin::PagesController does that). So an invalid create
    # currently raises RecordInvalid unhandled (a 500 in production) instead of
    # re-rendering the form via `response_for :invalid`. Characterizing the
    # current behavior; revisit if rescue_action is ever wired up.
    it 'raises on invalid input and persists nothing (latent bug: rescue_action is dead)' do
      expect {
        post :create, params: { snippet: { name: '', content: 'x' } }
      }.to raise_error(ActiveRecord::RecordInvalid)

      expect(Snippet.where(name: '')).to be_empty
    end
  end

  describe 'PUT #update' do
    it 'updates the snippet and redirects' do
      snippet = create(:snippet, name: 'editme', content: 'old')

      put :update, params: { id: snippet.id, snippet: { content: 'new' } }

      expect(response).to be_redirect
      expect(snippet.reload.content).to eq('new')
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the snippet and redirects' do
      snippet = create(:snippet, name: 'goner')

      expect {
        delete :destroy, params: { id: snippet.id }
      }.to change(Snippet, :count).by(-1)

      expect(response).to be_redirect
    end
  end

  describe 'authorization' do
    it 'denies a user without editor privileges' do
      allow(controller).to receive(:current_user).and_return(create(:user, email: 'plain@example.com'))

      get :index

      expect(response).to be_redirect
      expect(flash[:error]).to be_present
    end
  end
end
