require 'spec_helper'

# Exercises Admin::PagesHelper — small presentation helpers used by the page
# editor (class/filter lookups, meta-error detection, description cleanup,
# parent-page select options, and the revert confirmation copy).
describe Admin::PagesHelper, type: :helper do
  describe '#class_of_page' do
    it 'returns the assigned page class' do
      helper.instance_variable_set(:@page, Page.new)
      expect(helper.class_of_page).to eq(Page)
    end
  end

  describe '#filter' do
    it "returns the first part's filter when parts are present" do
      part = double('PagePart', filter: 'markdown')
      helper.instance_variable_set(:@page, double('Page', parts: [part]))
      expect(helper.filter).to eq('markdown')
    end

    it 'returns nil when there are no parts' do
      helper.instance_variable_set(:@page, double('Page', parts: []))
      expect(helper.filter).to be_nil
    end
  end

  describe '#meta_errors?' do
    # Admin::PagesHelper#meta_errors? is shadowed by ApplicationHelper#meta_errors?
    # in the view ancestry, so `helper.meta_errors?` would call the wrong one.
    # Bind this module's implementation to the helper to exercise it directly.
    def meta_errors?
      Admin::PagesHelper.instance_method(:meta_errors?).bind(helper).call
    end

    it 'is true when slug has an error' do
      page = Page.new
      page.errors.add(:slug, 'is invalid')
      helper.instance_variable_set(:@page, page)
      expect(meta_errors?).to be(true)
    end

    # NOTE: latent bug — errors[:attr] returns an array, and an empty array is
    # truthy, so `!!(errors[:slug] or errors[:breadcrumb])` is true even with no
    # meta errors. This implementation always returns true; characterizing it.
    it 'also (incorrectly) returns true when there are no meta errors' do
      helper.instance_variable_set(:@page, Page.new)
      expect(meta_errors?).to be(true)
    end
  end

  describe '#clean_page_description' do
    it 'strips leading/trailing whitespace and collapses internal runs' do
      page = double('Page', description: '  hello    world  ')
      expect(helper.clean_page_description(page)).to eq('hello world')
    end

    it 'removes tab characters entirely' do
      page = double('Page', description: "tab\there")
      expect(helper.clean_page_description(page)).to eq('tabhere')
    end
  end

  describe '#parent_page_options' do
    it 'builds options_for_select from the available parent pages' do
      home = FactoryBot.create(:home, title: 'Home')
      child = FactoryBot.create(:page, title: 'Child', slug: 'child', parent: home)
      current_site = double('Site', homepage_id: home.id)
      allow(Page).to receive(:parent_pages).with(home.id).and_return([home])

      html = helper.parent_page_options(current_site, child)

      expect(html).to include('Home')
      expect(html).to include("value=\"#{home.id}\"")
    end
  end

  describe '#revert_confirmation_message' do
    it 'includes the version date and time' do
      message = helper.revert_confirmation_message(update_date: 'July 29, 2026', update_time: '10:00 AM')
      expect(message).to include('July 29, 2026')
      expect(message).to include('10:00 AM')
    end
  end
end
