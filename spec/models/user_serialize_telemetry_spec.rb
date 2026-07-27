require 'spec_helper'

# Load the REAL multi_site scoping code (the extension is not activated in the
# dummy test app) so we reproduce the exact production site-scope on User.
require File.expand_path(
  '../../vendor/extensions/multi-site-extension/lib/multi_site/scoped_model', __dir__
)

# Telemetry for the intermittent CMS logout (issue #1040). This is observe-only:
# it must NOT change Devise's behavior, and must report exactly when a valid user
# is excluded from session deserialization by the site scope.
describe 'User.serialize_from_session telemetry (issue #1040)', type: :model do
  # Apply the production multi_site User scope for this example group only, then
  # restore it (config.order = "random", so a leaked default_scope would corrupt
  # other specs).
  around do |example|
    original_default_scopes = User.default_scopes.dup

    added_page_accessor = false
    unless Page.respond_to?(:current_site)
      Page.singleton_class.send(:attr_accessor, :current_site)
      added_page_accessor = true
    end

    unless User.singleton_class.include?(MultiSite::ScopedModel::ScopedClassMethods)
      User.extend(MultiSite::ScopedModel::ScopedClassMethods)
    end
    User.class_eval { default_scope { joins(user_scope_condition) } }

    begin
      example.run
    ensure
      User.default_scopes = original_default_scopes
      if added_page_accessor
        Page.singleton_class.send(:remove_method, :current_site)
        Page.singleton_class.send(:remove_method, :current_site=)
      end
      Thread.current[:trusty_request_host] = nil
    end
  end

  let(:site_a) { create(:site) }
  let(:site_b) { create(:site) }

  # Editor assigned to site_a only.
  let(:editor) do
    user = create(:user, email: 'editor@example.com')
    AdminsSite.create!(admin: user, site: site_a)
    user
  end

  def serialize
    User.serialize_from_session(editor.id, editor.authenticatable_salt)
  end

  context 'when current_site excludes an otherwise-valid user (the bug)' do
    before { Page.current_site = site_b }

    it 'still returns nil — behavior is unchanged vs the scoped default' do
      expect(serialize).to be_nil
    end

    it 'reports the miss to the log with context and a classification' do
      Thread.current[:trusty_request_host] = site_a.base_domain # host they belong to
      expect(Rails.logger).to receive(:warn).with(/CMS site-scope logout/)
      serialize
    end

    it 'classifies a host-they-belong-to mismatch as a race' do
      Thread.current[:trusty_request_host] = site_a.base_domain
      ctx = TrustyCms::SiteScopeAuthReporter.build_context(editor)
      expect(ctx[:classification]).to eq('race')
      expect(ctx[:user_id]).to eq(editor.id)
      expect(ctx[:current_site_id]).to eq(site_b.id)
    end

    it 'classifies a host they are not assigned to as genuine_cross_site' do
      Thread.current[:trusty_request_host] = site_b.base_domain # host they do NOT belong to
      ctx = TrustyCms::SiteScopeAuthReporter.build_context(editor)
      expect(ctx[:classification]).to eq('genuine_cross_site')
    end
  end

  context 'when current_site includes the user (normal case)' do
    before { Page.current_site = site_a }

    it 'returns the user and reports nothing' do
      expect(Rails.logger).not_to receive(:warn).with(/CMS site-scope logout/)
      expect(serialize).to eq(editor)
    end
  end

  context 'when the session key maps to no user at all' do
    before { Page.current_site = site_a }

    it 'reports nothing (ordinary expired/invalid session)' do
      expect(Rails.logger).not_to receive(:warn).with(/CMS site-scope logout/)
      expect(User.serialize_from_session(0, 'nope')).to be_nil
    end
  end

  it 'never raises into the auth path if telemetry blows up' do
    Page.current_site = site_b
    allow(TrustyCms::SiteScopeAuthReporter).to receive(:build_context).and_raise('boom')
    allow(Rails.logger).to receive(:error)

    result = nil
    expect { result = serialize }.not_to raise_error
    expect(result).to be_nil
    expect(Rails.logger).to have_received(:error).with(/SiteScopeAuthReporter error/)
  end
end
