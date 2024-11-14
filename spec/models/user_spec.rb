require 'spec_helper'

describe User do
  describe '#role?' do
    let(:user) { create(:user) }

    it 'returns true for admin role' do
      user.admin = true
      expect(user.role?(:admin)).to be true
    end

    it 'returns false for non-admin role' do
      user.admin = false
      expect(user.role?(:admin)).to be false
    end
  end

  describe '#password_complexity' do
    let(:user) { build(:user) }

    it 'is valid with a complex password' do
      user.password = 'ComplexPass1!'
      expect(user).to be_valid
    end

    it 'is invalid with a simple password' do
      user.password = 'simple'
      user.valid?
      expect(user.errors[:password]).to include('Complexity requirement not met. Length should be 12 characters and include: 1 uppercase, 1 lowercase, 1 digit and 1 special character.')
    end
  end

  describe '#password_required?' do
    let(:user) { build(:user) }

    it 'returns false if skip_password_validation is true' do
      user.skip_password_validation = true
      expect(user.password_required?).to be false
    end

    it 'returns true if skip_password_validation is false' do
      user.skip_password_validation = false
      expect(user.password_required?).to be true
    end
  end
end