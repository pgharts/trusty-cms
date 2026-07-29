require 'spec_helper'

# Exercises Admin::NodeHelper, which renders the admin page-tree nodes. The
# partial-rendering entry points are driven with `render` stubbed (the real
# partials need the full admin layout), while the node-presentation helpers
# (title, icon, expander, expansion state) are exercised directly.
describe Admin::NodeHelper, type: :helper do
  let!(:home) { FactoryBot.create(:home, title: 'Home') }
  let(:page) { FactoryBot.create(:page, title: 'Child', slug: 'child', parent: home) }

  before do
    # image() lives in ApplicationHelper (not mixed into this helper) and returns
    # an <img> tag; stub it so the presentation helpers can be tested in isolation.
    allow(helper).to receive(:image) { |name, *| "<img data-name='#{name}'/>".html_safe }
    allow(helper).to receive(:cookies).and_return({})
  end

  describe '#prepare_page' do
    it 'extends the page with MenuRenderer and wires up the view' do
      result = helper.prepare_page(page)
      expect(result).to be(page)
      expect(result.view).to be(helper)
    end
  end

  describe '#homepage' do
    it 'returns the page with no parent' do
      expect(helper.homepage).to eq(home)
    end
  end

  describe '#show_all?' do
    it 'is true only on the remove action' do
      allow(helper.controller).to receive(:action_name).and_return('remove')
      expect(helper.show_all?).to be(true)

      allow(helper.controller).to receive(:action_name).and_return('index')
      expect(helper.show_all?).to be(false)
    end
  end

  describe '#expanded_rows' do
    it 'parses the expanded_rows cookie and always includes the homepage' do
      allow(helper).to receive(:cookies).and_return(expanded_rows: "#{page.id},not-a-number")

      rows = helper.expanded_rows

      expect(rows).to include(page.id)
      expect(rows).to include(home.id) # homepage is always expanded
    end

    it 'defaults to just the homepage when no cookie is set' do
      expect(helper.expanded_rows).to eq([home.id])
    end
  end

  # @current_node is normally set by render_node; set it directly so the
  # presentation helpers (which read it) can be exercised in isolation.
  def make_current(a_page)
    helper.instance_variable_set(:@current_node, helper.prepare_page(a_page))
  end

  describe 'node presentation' do
    before { make_current(page) }

    describe '#expanded' do
      it 'is true on the remove action regardless of cookie state' do
        allow(helper).to receive(:show_all?).and_return(true)
        expect(helper.expanded).to be(true)
      end
    end

    describe '#expander' do
      it 'is blank at the top level' do
        expect(helper.expander(0)).to eq('')
      end

      it 'is blank for a childless node' do
        make_current(page) # child has no children
        expect(helper.expander(1)).to eq('')
      end

      it 'renders a toggle image for a node with children at a nested level' do
        make_current(home) # home has the child page
        expect(helper.expander(1)).to include('<img')
      end
    end

    describe '#icon' do
      it 'renders an icon image' do
        expect(helper.icon).to include('<img')
      end
    end

    describe '#node_title' do
      it 'wraps the escaped title in a span' do
        expect(helper.node_title).to eq(%{<span class="title">Child</span>})
      end
    end

    describe '#page_type' do
      it 'is blank for a plain Page' do
        expect(helper.page_type).to eq('')
      end
    end

    describe '#spinner' do
      it 'renders a hidden spinner image' do
        expect(helper.spinner).to include('<img')
      end
    end
  end

  describe 'rendering entry points' do
    before { allow(helper).to receive(:render).and_return('<node/>'.html_safe) }

    it '#render_node accumulates rendered HTML and returns the index' do
      helper.instance_variable_set(:@rendered_html, '') # normally done by render_nodes
      expect(helper.render_node(page, 2)).to eq(2)
      expect(helper.instance_variable_get(:@rendered_html)).to eq('<node/>')
    end

    it '#render_nodes resets and returns the accumulated HTML' do
      expect(helper.render_nodes(page, 0)).to eq('<node/>')
    end

    it '#render_search_node renders the search partial' do
      helper.render_search_node(page)
      expect(helper.instance_variable_get(:@rendered_html)).to eq('<node/>')
    end
  end
end
