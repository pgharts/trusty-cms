require 'rails_helper'

# Full-stack smoke: routing -> Devise/Warden auth -> ResourceController ->
# responder -> JSON render -> model -> DB. Uses the JSON endpoints so the smoke
# doesn't depend on the (asset-pipeline-heavy) admin HTML layout, which can't be
# rendered in this test environment. This is a high-value regression net for a
# Rails/Ruby upgrade: it exercises the real request cycle end to end.
RSpec.describe 'Admin::Snippets requests', type: :request do
  let(:admin) { FactoryBot.create(:admin) }

  describe 'authentication' do
    it 'redirects an unauthenticated HTML request to sign-in' do
      get '/admin/snippets'
      expect(response).to redirect_to('/users/sign_in')
    end

    it 'returns 401 for an unauthenticated JSON request' do
      get '/admin/snippets.json'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'authorization' do
    it 'forbids a signed-in user without editor privileges (JSON)' do
      sign_in FactoryBot.create(:user, email: 'plain@example.com')
      get '/admin/snippets.json'
      expect(response).to have_http_status(:forbidden)
    end
  end

  context 'when signed in as an admin' do
    before { sign_in admin }

    it 'lists snippets as JSON' do
      FactoryBot.create(:snippet, name: 'listed', content: 'x')

      get '/admin/snippets.json'

      expect(response).to have_http_status(:ok)
      names = JSON.parse(response.body).map { |s| s['name'] }
      expect(names).to include('listed')
    end

    it 'creates a snippet via JSON' do
      expect {
        post '/admin/snippets.json', params: { snippet: { name: 'greeting', content: 'hi' } }
      }.to change(Snippet, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(Snippet.find_by(name: 'greeting').content).to eq('hi')
    end

    it 'updates a snippet via JSON' do
      snippet = FactoryBot.create(:snippet, name: 'editme', content: 'old')

      put "/admin/snippets/#{snippet.id}.json", params: { snippet: { content: 'new' } }

      expect(response).to have_http_status(:ok)
      expect(snippet.reload.content).to eq('new')
    end

    # NOTE: destroy DOES remove the record, but the JSON/XML responder in
    # Admin::ResourceController calls `head :deleted`, and :deleted is not a
    # valid Rack status symbol, so the response is a 500. Characterizing the
    # current behavior; the record removal is correct, only the status is wrong.
    it 'destroys the record but returns 500 from head :deleted (latent bug)' do
      snippet = FactoryBot.create(:snippet, name: 'goner')

      expect {
        delete "/admin/snippets/#{snippet.id}.json"
      }.to change(Snippet, :count).by(-1)

      expect(response).to have_http_status(:internal_server_error)
    end
  end
end
