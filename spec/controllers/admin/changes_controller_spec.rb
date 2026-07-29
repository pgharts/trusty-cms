require 'spec_helper'

# Exercises Admin::ChangesController, which builds a PaperTrail-backed diff view
# of recent page changes. Controller specs (views not rendered) let us drive the
# action and its private diff-building helpers without the admin HTML layout.
# PaperTrail behaviour is a plausible upgrade casualty, so this pins it down.
RSpec.describe Admin::ChangesController, type: :controller do
  routes { TrustyCms::Application.routes }

  let(:user) { create(:admin) }
  let!(:site) { create(:site) }

  before do
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
    # The multi-site extension (which provides #current_site) isn't loaded in the
    # dummy app, so stub it to the site our fixtures are scoped to.
    allow(controller).to receive(:current_site).and_return(site)
  end

  # Create a page scoped to the current site and give it a versioned change so
  # the controller has something to diff.
  def page_with_change
    page = create(:home, title: 'Original', site_id: site.id)
    PaperTrail.request(whodunnit: user.id.to_s) do
      page.update!(title: 'Updated Title')
    end
    page
  end

  # rails-controller-testing (which provides `assigns`) isn't in the bundle, so
  # read the controller's assigned ivars directly.
  def changes
    controller.instance_variable_get(:@changes)
  end

  describe 'GET #show' do
    it 'succeeds and assigns recent changes' do
      page_with_change

      get :show

      expect(response).to have_http_status(:ok)
      expect(changes).to be_present
    end

    it 'loads a single change when a version_id is given' do
      page = page_with_change
      version = PaperTrail::Version.where(item_type: 'Page', item_id: page.id).last

      get :show, params: { version_id: version.id }

      expect(response).to have_http_status(:ok)
      expect(changes.size).to eq(1)
      expect(changes.first[:id]).to eq(version.id)
    end

    it 'reports an error when the version_id is unknown' do
      get :show, params: { version_id: 0 }

      expect(changes).to be_empty
      expect(controller.instance_variable_get(:@change_error)).to eq('Version ID not found.')
    end

    it 'succeeds with no changes present' do
      get :show

      expect(response).to have_http_status(:ok)
      expect(changes).to eq([])
    end
  end
end
