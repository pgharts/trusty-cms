require 'spec_helper'

describe AdminsSite do
  it 'uses the admins_sites table' do
    expect(AdminsSite.table_name).to eq('admins_sites')
  end

  describe 'associations' do
    it 'belongs to an admin that is a User' do
      association = AdminsSite.reflect_on_association(:admin)
      expect(association.macro).to eq(:belongs_to)
      expect(association.options[:class_name]).to eq('User')
    end

    it 'belongs to a site' do
      expect(AdminsSite.reflect_on_association(:site).macro).to eq(:belongs_to)
    end
  end
end
