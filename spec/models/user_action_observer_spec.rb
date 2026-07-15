require 'spec_helper'

describe UserActionObserver do
  let(:observer) { UserActionObserver.instance }
  let(:user) { User.new }

  # Restore the original thread-local rather than clobbering it with nil, so
  # the spec stays isolated and order-independent.
  around do |example|
    original = Thread.current[:current_user]
    example.run
  ensure
    Thread.current[:current_user] = original
  end

  describe 'current_user' do
    it 'stores the current user on the class in thread-local storage' do
      UserActionObserver.current_user = user
      expect(UserActionObserver.current_user).to eq(user)
      expect(Thread.current[:current_user]).to eq(user)
    end

    it 'delegates the instance writer and reader to the class' do
      observer.current_user = user
      expect(UserActionObserver.current_user).to eq(user)
      expect(observer.current_user).to eq(user)
    end
  end

  describe 'callbacks' do
    it 'does not raise on before_create' do
      expect { observer.before_create(user) }.not_to raise_error
    end

    it 'does not raise on before_update' do
      expect { observer.before_update(user) }.not_to raise_error
    end
  end
end
