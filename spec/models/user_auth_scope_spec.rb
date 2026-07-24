require 'spec_helper'

# Load the REAL multi_site scoping code (the extension is not activated in the
# dummy test app, so we require the module directly). This lets us reproduce the
# exact production site-scope on User rather than a hand-rolled stand-in, so the
# test breaks if `user_scope_condition` ever changes.
require File.expand_path(
  '../../vendor/extensions/multi-site-extension/lib/multi_site/scoped_model', __dir__
)

# Regression test for issue #1040: non-admin (site-scoped) editors were being
# logged out because Devise deserializes the session user through User's
# site-scoped default_scope, and Page.current_site (process-global) frequently
# points at a site the editor is not assigned to -> the INNER JOIN excludes the
# row -> Devise sees nil -> logout.
#
# The fix makes all authentication lookups run `unscoped` (see User). Here we
# apply the real site-scope to User, point current_site at the WRONG site, and
# assert every auth entry point still resolves the editor.
describe 'User authentication is never site-scoped (issue #1040)', type: :model do
  # Apply the production multi_site scope to User for this example group only,
  # then fully restore it. config.order = "random", so leaking the default_scope
  # would corrupt unrelated specs.
  around do |example|
    original_default_scopes = User.default_scopes.dup

    # Mirror MultiSite::PageExtensions' class-level current_site accessor.
    added_page_accessor = false
    unless Page.respond_to?(:current_site)
      Page.singleton_class.send(:attr_accessor, :current_site)
      added_page_accessor = true
    end

    unless User.singleton_class.include?(MultiSite::ScopedModel::ScopedClassMethods)
      User.extend(MultiSite::ScopedModel::ScopedClassMethods)
    end
    # The real production default_scope for User (scoped_model.rb:28).
    User.class_eval { default_scope { joins(user_scope_condition) } }

    begin
      example.run
    ensure
      User.default_scopes = original_default_scopes
      if added_page_accessor
        Page.singleton_class.send(:remove_method, :current_site)
        Page.singleton_class.send(:remove_method, :current_site=)
      end
    end
  end

  let(:site_a) { create(:site) }
  let(:site_b) { create(:site) }

  # An editor assigned to site_a ONLY (row in admins_sites for site_a, none for site_b).
  let(:editor) do
    user = create(:user, email: 'editor@example.com')
    AdminsSite.create!(admin: user, site: site_a)
    user
  end

  before do
    # Simulate a request whose current site is the WRONG one for this editor.
    Page.current_site = site_b
  end

  it 'confirms the site-scope really does exclude the editor (bug precondition)' do
    # Scoped lookup: INNER JOIN admins_sites on site_b -> editor (site_a only) excluded.
    expect(User.where(id: editor.id).first).to be_nil
    # Unscoped: the editor obviously still exists.
    expect(User.unscoped.where(id: editor.id).first).to eq(editor)
  end

  it 'serialize_from_session resolves the editor despite the wrong current_site' do
    expect(
      User.serialize_from_session(editor.id, editor.authenticatable_salt)
    ).to eq(editor)
  end

  it 'find_first_by_auth_conditions resolves the editor despite the wrong current_site' do
    expect(
      User.find_first_by_auth_conditions(email: editor.email)
    ).to eq(editor)
  end

  it 'find_for_authentication resolves the editor despite the wrong current_site' do
    expect(
      User.find_for_authentication(email: editor.email)
    ).to eq(editor)
  end

  it 'the login-path email lookup resolves the editor despite the wrong current_site' do
    # Mirrors Admin::SessionsController#find_user after the fix.
    expect(
      User.unscoped.find_by(email: editor.email)
    ).to eq(editor)
  end
end
