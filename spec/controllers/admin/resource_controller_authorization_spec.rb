require 'spec_helper'

# Authorization for the multi_site setup (issue #1040): authentication is global
# (see User auth overrides), so a separate check enforces that a non-admin user
# may only reach the admin of a site they are assigned to. This exercises the
# pure predicate; Site / AdminsSite / User#sites all exist in engine core, so it
# does not require the multi_site extension to be active.
describe Admin::ResourceController, type: :controller do
  subject(:controller_instance) { described_class.new }

  let(:site_a) { create(:site) }
  let(:site_b) { create(:site) }

  def permitted?(user, site)
    controller_instance.send(:site_access_permitted?, user, site)
  end

  context 'a non-admin user assigned to site_a only' do
    let(:editor) do
      user = create(:user, admin: false)
      AdminsSite.create!(admin: user, site: site_a)
      user
    end

    it 'is permitted on their assigned site' do
      expect(permitted?(editor, site_a)).to be true
    end

    it 'is denied on a site they are not assigned to' do
      expect(permitted?(editor, site_b)).to be false
    end
  end

  it 'permits an admin on any site (site authorization is bypassed)' do
    admin = create(:admin, admin: true)
    expect(permitted?(admin, site_a)).to be true
    expect(permitted?(admin, site_b)).to be true
  end

  it 'permits when there is no current site (nothing to authorize against)' do
    editor = create(:user, admin: false)
    expect(permitted?(editor, nil)).to be true
  end

  it 'permits a nil user (authenticate_user! owns the unauthenticated case)' do
    expect(permitted?(nil, site_a)).to be true
  end

  it 'denies a non-admin user with no site assignments' do
    editor = create(:user, admin: false)
    expect(permitted?(editor, site_a)).to be false
  end
end
