require 'spec_helper'

# Exercises PageStatusController#refresh — a token-authenticated, no-CSRF JSON
# endpoint that publishes scheduled pages whose time has come. Auth is a bearer
# token compared with secure_compare; cover the reject paths and the publish
# behaviour.
RSpec.describe PageStatusController, type: :controller do
  routes { TrustyCms::Application.routes }
  # refresh skips authenticate_user!, but ApplicationController before-actions
  # still read current_user, which needs Warden injected on the request.
  include Devise::Test::ControllerHelpers

  let(:token) { 'secret-bearer-token' }

  def authorize!(value = token)
    request.headers['Authorization'] = "Bearer #{value}"
  end

  before do
    allow(Rails.application.credentials).to receive(:dig)
      .with(:trusty_cms, :page_status_bearer_token).and_return(token)
  end

  describe 'POST #refresh authentication' do
    it 'returns 401 when no token is provided' do
      post :refresh
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)['error']).to eq('Missing Bearer Token')
    end

    it 'returns 401 when the token is wrong' do
      authorize!('nope')
      post :refresh
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)['error']).to eq('Invalid Bearer Token')
    end
  end

  describe 'POST #refresh' do
    before { authorize! }

    it 'publishes scheduled pages whose publish time has passed' do
      due = create(:page, title: 'Due', slug: 'due', status_id: Status[:scheduled].id,
                          published_at: 1.day.ago)

      post :refresh

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['updated_page_ids']).to include(due.id)
      expect(due.reload.status_id).to eq(Status[:published].id)
    end

    it 'leaves future-scheduled pages alone' do
      future = create(:page, title: 'Future', slug: 'future', status_id: Status[:scheduled].id,
                             published_at: 1.day.from_now)

      post :refresh

      body = JSON.parse(response.body)
      expect(body['remaining_scheduled_page_ids']).to include(future.id)
      expect(body['message']).to match(/No scheduled pages/)
      expect(future.reload.status_id).to eq(Status[:scheduled].id)
    end
  end
end
