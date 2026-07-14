require 'spec_helper'

describe Page do
  let(:home) { FactoryBot.create(:home, title: 'Home') }

  describe 'paths' do
    it 'renders the root path as "/"' do
      expect(home.path).to eq('/')
    end

    it 'builds a child path from the parent path and slug' do
      parent = FactoryBot.create(:page, title: 'Parent', slug: 'parent', parent: home, status_id: Status[:published].id)
      expect(parent.path).to eq('/parent')
    end

    it 'builds a nested path across multiple ancestors' do
      parent = FactoryBot.create(:page, title: 'Parent', slug: 'parent', parent: home, status_id: Status[:published].id)
      child  = FactoryBot.create(:page, title: 'Child', slug: 'child', parent: parent, status_id: Status[:published].id)
      expect(child.path).to eq('/parent/child')
    end

    it 'returns an empty string when the slug is blank' do
      expect(FactoryBot.build(:page, slug: '').path).to eq('')
    end

    it '#child_path joins the page path with the child slug' do
      parent = FactoryBot.create(:page, title: 'Parent', slug: 'parent', parent: home, status_id: Status[:published].id)
      expect(home.child_path(parent)).to eq('/parent')
    end

    it 'aliases #url to #path' do
      expect(home.url).to eq(home.path)
    end
  end

  describe 'status' do
    it '#status returns the Status for the status_id' do
      expect(home.status).to eq(Status[:published])
      expect(home.status.name).to eq('Published')
    end

    it '#status= assigns the status_id from a Status' do
      page = FactoryBot.build(:page)
      page.status = Status[:hidden]
      expect(page.status_id).to eq(Status[:hidden].id)
    end

    it '#published? is true only for published pages' do
      draft = FactoryBot.create(:page, title: 'Draft', slug: 'draft', parent: home, status_id: Status[:draft].id)
      expect(home.published?).to be(true)
      expect(draft.published?).to be(false)
    end

    it '#hidden? is true only for hidden pages' do
      # Built (not created) to avoid the handle_hidden_status save callback,
      # which references an unset config method in this environment.
      hidden = FactoryBot.build(:page, title: 'Hidden', slug: 'hidden', parent: home, status_id: Status[:hidden].id)
      expect(hidden.hidden?).to be(true)
      expect(home.hidden?).to be(false)
    end

    it '#scheduled? is true only for scheduled pages' do
      scheduled = FactoryBot.create(:page, title: 'Sched', slug: 'sched', parent: home, status_id: Status[:scheduled].id)
      expect(scheduled.scheduled?).to be(true)
      expect(home.scheduled?).to be(false)
    end

    it 'stamps published_at when a page is published' do
      page = FactoryBot.create(:page, title: 'Pub', slug: 'pub', parent: home, status_id: Status[:published].id)
      expect(page.published_at).to be_present
    end

    it 'does not stamp published_at for an unpublished page' do
      draft = FactoryBot.create(:page, title: 'Draft2', slug: 'draft2', parent: home, status_id: Status[:draft].id)
      expect(draft.published_at).to be_nil
    end
  end

  describe 'parts' do
    it '#part returns the named part' do
      home.parts.create(name: 'body', content: 'x')
      expect(home.part('body').content).to eq('x')
    end

    it '#part? reflects whether the part exists' do
      home.parts.create(name: 'body', content: 'x')
      expect(home.part?('body')).to be(true)
      expect(home.part?('sidebar')).to be(false)
    end

    it '#inherits_part? is true when an ancestor has the part but the page does not' do
      home.parts.create(name: 'body', content: 'x')
      child = FactoryBot.create(:page, title: 'Child', slug: 'child', parent: home, status_id: Status[:published].id)
      expect(child.part?('body')).to be(false)
      expect(child.inherits_part?('body')).to be(true)
    end

    it '#has_or_inherits_part? covers both direct and inherited parts' do
      home.parts.create(name: 'body', content: 'x')
      child = FactoryBot.create(:page, title: 'Child', slug: 'child', parent: home, status_id: Status[:published].id)
      expect(child.has_or_inherits_part?('body')).to be(true)
      expect(child.has_or_inherits_part?('missing')).to be(false)
    end
  end

  describe 'fields' do
    it '#field looks up a field by name, case-insensitively' do
      home.fields.create(name: 'Description', content: 'desc')
      expect(home.field('description').content).to eq('desc')
      expect(home.field(:Description).content).to eq('desc')
    end

    it '#field returns nil for an unknown field' do
      expect(home.field('nope')).to be_nil
    end
  end

  describe 'rendering' do
    it '#render renders the body part when there is no layout' do
      page = FactoryBot.create(:page, title: 'NoLayout', slug: 'nl', parent: home, status_id: Status[:published].id)
      page.parts.create(name: 'body', content: 'Body: <r:title />')
      expect(page.render).to eq('Body: NoLayout')
    end

    it '#render renders through the layout when one is present' do
      layout = Layout.create!(name: 'Simple', content: 'Layout: <r:title />')
      page = FactoryBot.create(:page, title: 'WithLayout', slug: 'wl', parent: home, status_id: Status[:published].id, layout: layout)
      expect(page.render).to eq('Layout: WithLayout')
    end

    it '#render_part returns an empty string for a missing part' do
      expect(home.render_part(:nonexistent)).to eq('')
    end

    it '#render_snippet parses the snippet content in the page context' do
      snippet = FactoryBot.build(:snippet, name: 'greeting', content: 'Hello from <r:title />')
      expect(home.render_snippet(snippet)).to eq('Hello from Home')
    end
  end

  describe '.new_with_defaults' do
    it 'builds a page with the configured default parts, fields, and status' do
      page = Page.new_with_defaults
      expect(page.parts.map(&:name)).to eq(%w[body extended])
      expect(page.fields.map(&:name)).to eq(%w[Keywords Description])
      expect(page.status).to eq(Status[:draft])
    end
  end

  describe 'class helpers' do
    it '.root returns the parentless page' do
      home
      expect(Page.root).to eq(home)
    end

    it '.date_column_names lists the date/time columns' do
      expect(Page.date_column_names).to include('created_at', 'updated_at', 'published_at')
    end

    it '.descendant_class returns Page for blank/nil/"Page"' do
      expect(Page.descendant_class(nil)).to eq(Page)
      expect(Page.descendant_class('')).to eq(Page)
      expect(Page.descendant_class('Page')).to eq(Page)
    end

    it '.descendant_class raises for an invalid class name' do
      expect { Page.descendant_class('NotARealPage') }.to raise_error(ArgumentError)
    end
  end

  describe 'response defaults' do
    it '#cache? is true' do
      expect(home.cache?).to be(true)
    end

    it '#response_code is 200' do
      expect(home.response_code).to eq(200)
    end

    it '#headers is an empty hash' do
      expect(home.headers).to eq({})
    end
  end
end
