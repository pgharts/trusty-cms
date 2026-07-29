require 'spec_helper'
require 'rack/test'

# Exercises Admin::AssetsController, which overrides the ResourceController CRUD
# with custom upload handling (process_uploaded_asset, maybe_compress,
# failure_response, set_owner_or_editor). Uses the JSON/partial endpoints so the
# specs don't depend on the asset-pipeline-heavy admin HTML layout. High-value
# regression net for a Rails/Ruby upgrade — file uploads and content-type
# negotiation are common breakage points.
RSpec.describe Admin::AssetsController, type: :controller do
  routes { TrustyCms::Application.routes }

  let(:user) { create(:admin) }
  let(:fixtures_path) { TrustyCms::Engine.root.join('spec', 'fixtures', 'files') }

  before do
    # approved_content_types derives from the AssetType registry, which is empty
    # by default; register the canonical set (shared with asset_spec) so uploads
    # of text/plain, images, etc. can be approved. See AssetTypeRegistry.
    register_standard_asset_types

    # public_url generation needs a host; controller specs don't set one on the
    # Disk service the way a real request would.
    @previous_active_storage_url_options = ActiveStorage::Current.url_options
    ActiveStorage::Current.url_options = { host: 'test.host', protocol: 'http' }

    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
  end

  after do
    ActiveStorage::Current.url_options = @previous_active_storage_url_options
  end

  # A plain stub (not an rspec double) so it can be assigned in an `around`
  # hook, which runs outside the per-test double lifecycle. api_key: nil makes
  # should_compress? false, so uploads skip Kraken compression.
  around do |example|
    original_kraken = defined?($kraken) ? $kraken : nil
    $kraken = Struct.new(:api_key).new(nil)
    example.run
    $kraken = original_kraken
  end

  def upload(filename, content_type)
    Rack::Test::UploadedFile.new(fixtures_path.join(filename), content_type)
  end

  describe 'POST #uploader' do
    it 'returns the asset url when the upload succeeds' do
      expect {
        post :uploader, params: { upload: upload('sample.txt', 'text/plain') }, format: :json
      }.to change(Asset, :count).by(1)

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to have_key('url')
    end

    it 'records the uploading user as owner/editor' do
      post :uploader, params: { upload: upload('sample.txt', 'text/plain') }, format: :json

      asset = Asset.last
      expect(asset.created_by_id).to eq(user.id)
      expect(asset.updated_by_id).to eq(user.id)
    end

    it 'returns unsupported media type for disallowed content types' do
      expect(Asset).not_to receive(:create)

      post :uploader, params: { upload: upload('sample.txt', 'application/x-unsupported') }, format: :json

      expect(response).to have_http_status(:unsupported_media_type)
      expect(JSON.parse(response.body)['error']).to eq('Unsupported file type.')
      expect(flash[:error]).to eq('Unsupported file type.')
    end

    it 'rejects the generic octet-stream content type with a notice' do
      post :uploader, params: { upload: upload('sample.txt', 'application/octet-stream') }, format: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['error']).to match(/valid extension/)
      expect(flash[:notice]).to match(/valid extension/)
    end

    it 'returns unprocessable entity when no file is provided' do
      post :uploader, params: {}, format: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['error']).to eq('No file uploaded.')
      expect(flash[:error]).to eq('No file uploaded.')
    end
  end

  describe 'POST #create' do
    it 'creates an asset from an uploaded file and redirects (HTML)' do
      expect {
        post :create, params: { asset: { asset: [upload('sample.txt', 'text/plain')] } }
      }.to change(Asset, :count).by(1)

      expect(response).to be_redirect
    end

    it 'redirects back to new with a flash error when the upload is unsupported' do
      expect {
        post :create, params: { asset: { asset: [upload('sample.txt', 'application/x-unsupported')] } }
      }.not_to change(Asset, :count)

      expect(response).to redirect_to(new_admin_asset_path)
      expect(flash[:error]).to eq('Unsupported file type.')
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the asset and redirects' do
      asset = Asset.create!(asset: upload('sample.txt', 'text/plain'), caption: '')

      expect {
        delete :destroy, params: { id: asset.id }
      }.to change(Asset, :count).by(-1)

      expect(response).to be_redirect
    end
  end
end
