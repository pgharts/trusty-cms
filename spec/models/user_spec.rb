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

  describe '#role?' do
    let(:user) { build(:user) }

    it 'maps :designer to the designer flag' do
      user.designer = true
      expect(user.role?(:designer)).to be(true)
    end

    it 'maps :content_editor to the content_editor flag' do
      user.content_editor = true
      expect(user.role?(:content_editor)).to be(true)
    end

    it 'returns false for an unknown role' do
      expect(user.role?(:wizard)).to be(false)
    end
  end

  describe 'role predicates' do
    let(:user) { build(:user) }

    it '#admin? reflects the admin flag' do
      user.admin = true
      expect(user.admin?).to be(true)
    end

    it '#designer? reflects the designer flag' do
      user.designer = true
      expect(user.designer?).to be(true)
    end

    it '#content_editor? reflects the content_editor flag' do
      user.content_editor = true
      expect(user.content_editor?).to be(true)
    end

    it '#editor? reflects the designer flag' do
      # Note: editor? currently returns the designer flag (not a distinct column).
      user.designer = true
      expect(user.editor?).to be(true)
    end
  end

  describe '#name' do
    it 'joins the first and last name' do
      user = build(:user, first_name: 'Jane', last_name: 'Doe')
      expect(user.name).to eq('Jane Doe')
    end
  end

  describe '#locale' do
    it 'is en' do
      expect(build(:user).locale).to eq('en')
    end
  end

  describe '#scoped_site?' do
    let(:user) { build(:user) }

    it 'is false when the user has no sites' do
      expect(user.scoped_site?).to be(false)
    end

    it 'is true when the user has sites' do
      allow(user).to receive(:sites).and_return([double('Site')])
      expect(user.scoped_site?).to be(true)
    end
  end

  describe 'default ordering' do
    it 'orders users by last name' do
      create(:user, first_name: 'A', last_name: 'Zeta', email: 'z@test.com')
      create(:user, first_name: 'B', last_name: 'Alpha', email: 'a@test.com')
      expect(User.all.map(&:last_name)).to eq(%w[Alpha Zeta])
    end
  end
end