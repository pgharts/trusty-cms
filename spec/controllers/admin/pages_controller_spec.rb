require 'spec_helper'

# Exercises Admin::PagesController — the most heavily customized ResourceController
# subclass (search, restore, per-site edit guards, meta-row setup, ordering).
# Controller specs (views not rendered) let us drive the actions and their many
# private helpers without the asset-pipeline-heavy admin HTML layout. This is the
# highest-blast-radius controller in the app, so keep it green across the Rails 8 bump.
RSpec.describe Admin::PagesController, type: :controller do
  routes { TrustyCms::Application.routes }

  let(:admin) { create(:admin) }
  let!(:home) { create(:home, title: 'Home') }

  before do
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_user).and_return(admin)
    # #current_site / Page.current_site / Page.homepage come from the multi-site
    # extension, which isn't loaded in the dummy app; stub the touch points.
    allow(Page).to receive(:current_site).and_return(nil)
    allow(Page).to receive(:homepage).and_return(home)
  end

  describe 'GET #index' do
    it 'succeeds and sets up the site/homepage/search' do
      get :index
      expect(response).to have_http_status(:ok)
      expect(controller.instance_variable_get(:@homepage)).to eq(home)
    end
  end

  describe 'GET #new' do
    it 'builds a new page with defaults' do
      get :new
      expect(response).to have_http_status(:ok)
      page = controller.instance_variable_get(:@page)
      expect(page).to be_a(Page).and be_new_record
    end

    it 'roots a top-level page at "/" when no parent is given' do
      get :new
      expect(controller.instance_variable_get(:@page).slug).to eq('/')
    end

    it 'sets the parent_id from page_id' do
      get :new, params: { page_id: home.id }
      expect(controller.instance_variable_get(:@page).parent_id).to eq(home.id)
    end
  end

  describe 'GET #edit' do
    context 'when the page belongs to a site the admin can access' do
      let(:site) { create(:site) }
      let(:page) { create(:page, title: 'Editable', parent: home, site_id: site.id) }

      before { admin.sites << site }

      it 'succeeds and loads edit assigns' do
        get :edit, params: { id: page.id }

        expect(response).to have_http_status(:ok)
        expect(controller.instance_variable_get(:@page)).to eq(page)
        expect(controller.instance_variable_get(:@page_url)).to be_present
      end
    end

    context 'when the page belongs to a site the admin cannot access' do
      let(:site) { create(:site) }
      let(:page) { create(:page, title: 'Forbidden', parent: home, site_id: site.id) }

      it 'redirects back to the pages index' do
        get :edit, params: { id: page.id }
        expect(response).to redirect_to(admin_pages_url)
      end
    end
  end

  describe 'POST #create' do
    it 'creates a page and redirects' do
      expect {
        post :create, params: { page: { title: 'Fresh', slug: 'fresh', breadcrumb: 'Fresh', parent_id: home.id } }
      }.to change(Page, :count).by(1)

      expect(response).to be_redirect
    end

    it 're-renders new via the rescue_from validation_error handler when invalid' do
      expect {
        post :create, params: { page: { title: '', slug: '', breadcrumb: '', parent_id: home.id } }
      }.not_to change(Page, :count)

      expect(flash[:error]).to be_present
    end
  end

  describe 'PUT #update' do
    it 'updates the page and redirects' do
      page = create(:page, title: 'Before', parent: home)

      put :update, params: { id: page.id, page: { title: 'After' } }

      expect(response).to be_redirect
      expect(page.reload.title).to eq('After')
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the page and counts descendants' do
      page = create(:page, title: 'Doomed', parent: home)

      expect {
        delete :destroy, params: { id: page.id }
      }.to change(Page, :count).by(-1)

      expect(response).to be_redirect
    end
  end

  describe 'GET #search' do
    it 'returns matching pages when a query is present' do
      create(:page, title: 'Findable', slug: 'findable', parent: home)

      get :search, params: { site_id: nil, search: { query: 'Findable' } }

      expect(response).to have_http_status(:ok)
      titles = controller.instance_variable_get(:@pages).map(&:title)
      expect(titles).to include('Findable')
    end

    it 'does not run a query when none is given' do
      get :search, params: { site_id: '' }
      expect(controller.instance_variable_get(:@pages)).to be_nil
    end
  end

  describe 'POST #save_table_position' do
    it 'saves the new order and returns ok' do
      allow(Page).to receive(:save_order)
      post :save_table_position, params: { new_position: %w[1 2 3] }
      expect(response).to have_http_status(:ok)
      expect(Page).to have_received(:save_order).with(%w[1 2 3])
    end
  end

  describe 'PUT #restore' do
    # NOTE: latent bug / Rails 8 upgrade blocker — restore_page_version calls
    # PaperTrail's `reify`, which YAML-loads the stored version. Under Psych 4+
    # (psych 5.4 is pinned) safe-loading rejects ActiveSupport::TimeWithZone
    # because no permitted classes are configured, so restoring any page that has
    # a timestamp in its versioned state raises Psych::DisallowedClass. Page
    # restore is effectively broken until paper_trail's serializer is configured
    # with permitted classes (e.g. via ActiveRecord::Base.yaml_column_permitted_classes
    # or a custom serializer). Characterizing current behavior.
    it 'currently fails to reify a versioned page (Psych safe-load blocker)' do
      page = create(:page, title: 'V1', parent: home)
      PaperTrail.request(whodunnit: admin.id.to_s) { page.update!(title: 'V2') }

      expect {
        put :restore, params: { id: page.id, version_index: 1 }
      }.to raise_error(Psych::DisallowedClass, /TimeWithZone/)
    end
  end
end
