require 'spec_helper'
require 'rack/test'

RSpec.describe Admin::AssetsController, type: :controller do
  routes { TrustyCms::Engine.routes }

  let(:user) { create(:admin) }
  let(:fixtures_path) { TrustyCms::Engine.root.join('spec', 'fixtures', 'files') }

  before do
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
  end

  around do |example|
    original_kraken = defined?($kraken) ? $kraken : nil
    $kraken = double('KrakenClient', api_key: nil)
    example.run
    $kraken = original_kraken
  end

  describe 'POST #uploader' do
    it 'returns the asset url when the upload succeeds' do
      file = Rack::Test::UploadedFile.new(fixtures_path.join('sample.ics'), 'text/calendar')
      asset_storage = double('AssetStorage', url: '/assets/sample.ics')
      asset = instance_double(Asset,
                              valid?: true,
                              asset: asset_storage,
                              page_attachments: double('Assoc', build: nil),
                              id: 1)

      allow(asset).to receive(:created_by_id=)
      allow(asset).to receive(:updated_by_id=)
      allow(asset).to receive(:save!)
      allow(Asset).to receive(:create).and_return(asset)
      allow(controller).to receive(:maybe_compress).and_return(file)

      post :uploader, params: { upload: file }, format: :json

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq('url' => '/assets/sample.ics')
      expect(controller).to have_received(:maybe_compress).with(file)
      expect(Asset).to have_received(:create).with(asset: file, caption: '')
    end

    it 'returns unsupported media type for disallowed content types' do
      file = Rack::Test::UploadedFile.new(fixtures_path.join('sample.txt'), 'text/plain')

      expect(Asset).not_to receive(:create)

      post :uploader, params: { upload: file }, format: :json

      expect(response).to have_http_status(:unsupported_media_type)
      expect(JSON.parse(response.body)['error']).to eq('Unsupported file type.')
      expect(flash[:error]).to eq('Unsupported file type.')
    end

    it 'returns unprocessable entity when no file is provided' do
      post :uploader, params: {}, format: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['error']).to eq('No file uploaded.')
      expect(flash[:error]).to eq('No file uploaded.')
    end
  end
end
