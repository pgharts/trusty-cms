require 'spec_helper'

# LoginSystem is TrustyCms's custom role-based authorization layer, mixed into
# ApplicationController. The class-level access rules are pure logic, so pin
# them ahead of any Rails upgrade without needing a full request cycle.
describe LoginSystem do
  describe 'role-based access (.only_allow_access_to / .user_has_access_to_action?)' do
    let(:controller_class) do
      Class.new(ActionController::Base) do
        include LoginSystem
        only_allow_access_to :index, :show,
                             when: %i[admin designer],
                             denied_message: 'You need editor privileges.'
      end
    end

    it 'records the declared permissions per action' do
      perms = controller_class.controller_permissions[:index]
      expect(perms[:when]).to eq(%i[admin designer])
      expect(perms[:denied_message]).to eq('You need editor privileges.')
    end

    it 'grants access to a user with an allowed role' do
      expect(controller_class.user_has_access_to_action?(User.new(admin: true), :index)).to be(true)
      expect(controller_class.user_has_access_to_action?(User.new(designer: true), :show)).to be(true)
    end

    it 'denies a user without an allowed role' do
      expect(controller_class.user_has_access_to_action?(User.new, :index)).to be(false)
    end

    it 'denies an anonymous (nil) user' do
      expect(controller_class.user_has_access_to_action?(nil, :index)).to be(false)
    end

    it 'allows any action that has no declared restriction' do
      expect(controller_class.user_has_access_to_action?(User.new, :unlisted_action)).to be(true)
    end
  end

  describe 'conditional access (:if)' do
    let(:controller_class) do
      Class.new(ActionController::Base) do
        include LoginSystem
        only_allow_access_to :index, if: :allowed?
        def allowed?
          true
        end
      end
    end

    it 'delegates to the named predicate on the controller' do
      expect(controller_class.user_has_access_to_action?(User.new, :index)).to be(true)
    end
  end

  # NOTE: .login_required? / .login_required reference `filter_chain`, a Rails
  # API removed years ago, and would raise NoMethodError if called. They are
  # dead code today (only commented-out call sites remain), so they are not
  # exercised here. Flagging for removal or repair rather than pinning.
end
