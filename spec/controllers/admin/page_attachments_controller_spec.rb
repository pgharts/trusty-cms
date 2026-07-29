require 'spec_helper'
require 'rack/test'

# Exercises Admin::PageAttachmentsController, whose custom #load_model builds a
# PageAttachment from an asset_id (+ optional page_id) and rescues a missing
# asset. Controller spec (views not rendered) drives the action and its
# before-action without needing the admin HTML layout.
RSpec.describe Admin::PageAttachmentsController, type: :controller do
  routes { TrustyCms::Application.routes }

  let(:user) { create(:admin) }
  let(:fixtures_path) { TrustyCms::Engine.root.join('spec', 'fixtures', 'files') }
  let(:asset) do
    Asset.create!(asset: Rack::Test::UploadedFile.new(fixtures_path.join('sample.txt'), 'text/plain'), caption: '')
  end

  before do
    register_standard_asset_types # shared canonical AssetTypes (see AssetTypeRegistry)
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe 'GET #new' do
    it 'builds a PageAttachment for the asset with a new (unsaved) page' do
      get :new, params: { asset_id: asset.id }

      expect(response).to have_http_status(:ok)
      model = controller.instance_variable_get(:@page_attachment)
      expect(model).to be_a(PageAttachment)
      expect(model.asset).to eq(asset)
      expect(model.page).to be_a(Page).and be_new_record
    end

    it 'associates an existing page when a page_id is given' do
      page = create(:home, title: 'Attach Target')

      get :new, params: { asset_id: asset.id, page_id: page.id }

      expect(controller.instance_variable_get(:@page)).to eq(page)
    end

    # NOTE: latent bug — load_model rescues a missing asset with
    # `render nothing: true`, but the `nothing:` option was removed in Rails 5.1.
    # It's now ignored, so Rails falls through to rendering the (nonexistent)
    # `new` template and raises MissingTemplate instead of returning an empty
    # body. Characterizing current behavior; the fix is `head :no_content`.
    # This is exactly the kind of breakage a Rails 8 upgrade should clean up.
    it 'raises MissingTemplate for a missing asset (broken rescue path)' do
      expect {
        get :new, params: { asset_id: 0 }
      }.to raise_error(ActionView::MissingTemplate)
    end
  end
end
