require 'spec_helper'

describe 'StandardTags: children tags' do
  def render(page, input)
    page.send(:parse, input)
  end

  let(:home) { FactoryBot.create(:home) }

  # Three published children (ascending published_at) plus one draft, so we can
  # exercise ordering, status filtering, limit/offset and pagination.
  before do
    FactoryBot.create(:page, title: 'Apple',  slug: 'apple',  parent: home, status_id: Status[:published].id, published_at: Time.zone.local(2020, 1, 1))
    FactoryBot.create(:page, title: 'Banana', slug: 'banana', parent: home, status_id: Status[:published].id, published_at: Time.zone.local(2020, 1, 2))
    FactoryBot.create(:page, title: 'Cherry', slug: 'cherry', parent: home, status_id: Status[:published].id, published_at: Time.zone.local(2020, 1, 3))
    FactoryBot.create(:page, title: 'Zeta',   slug: 'zeta',   parent: home, status_id: Status[:draft].id)
  end

  describe '<r:children>' do
    it 'expands its contents' do
      expect(render(home, '<r:children>hello</r:children>')).to eq('hello')
    end
  end

  describe '<r:children:count>' do
    it 'counts published children by default status' do
      expect(render(home, '<r:children:count status="published" />')).to eq('3')
    end

    it 'counts all non-virtual children with status="all"' do
      expect(render(home, '<r:children:count status="all" />')).to eq('4')
    end
  end

  describe '<r:children:each>' do
    it 'iterates published children ordered by published_at ascending' do
      expect(render(home, '<r:children:each status="published"><r:title /> </r:children:each>'))
        .to eq('Apple Banana Cherry ')
    end

    it 'orders by a given field and direction' do
      expect(render(home, '<r:children:each status="published" by="title" order="desc"><r:title /> </r:children:each>'))
        .to eq('Cherry Banana Apple ')
    end

    it 'honors the limit attribute' do
      expect(render(home, '<r:children:each status="published" by="title" limit="2"><r:title /> </r:children:each>'))
        .to eq('Apple Banana ')
    end

    it 'honors the offset attribute' do
      expect(render(home, '<r:children:each status="published" by="title" offset="1"><r:title /> </r:children:each>'))
        .to eq('Banana Cherry ')
    end

    it 'includes non-virtual draft pages with status="all"' do
      expect(render(home, '<r:children:each status="all" by="title"><r:title /> </r:children:each>'))
        .to eq('Apple Banana Cherry Zeta ')
    end

    it 'raises when the by attribute is not a valid field' do
      expect { render(home, '<r:children:each status="published" by="bogus"><r:title /></r:children:each>') }
        .to raise_error(StandardTags::TagError, /`by'/)
    end

    it 'raises when the order attribute is invalid' do
      expect { render(home, '<r:children:each status="published" order="sideways"><r:title /></r:children:each>') }
        .to raise_error(StandardTags::TagError, /`order'/)
    end

    it 'raises when the status attribute is not a valid status' do
      expect { render(home, '<r:children:each status="bogus"><r:title /></r:children:each>') }
        .to raise_error(StandardTags::TagError, /`status'/)
    end

    it 'raises when the status attribute is omitted' do
      expect { render(home, '<r:children:each><r:title /></r:children:each>') }
        .to raise_error(StandardTags::TagError, /`status'/)
    end

    it 'raises when limit is not a positive number' do
      expect { render(home, '<r:children:each status="published" limit="x"><r:title /></r:children:each>') }
        .to raise_error(StandardTags::TagError, /limit/)
    end
  end

  describe 'child context tags inside <r:children:each>' do
    it 'maps <r:child> attribute tags to the current child' do
      expect(render(home, '<r:children:each status="published" by="title"><r:child><r:title /></r:child> </r:children:each>'))
        .to eq('Apple Banana Cherry ')
    end

    it 'renders <r:if_first> only for the first child' do
      expect(render(home, '<r:children:each status="published" by="title"><r:if_first>[first]</r:if_first><r:title /> </r:children:each>'))
        .to eq('[first]Apple Banana Cherry ')
    end

    it 'renders <r:unless_first> for every child but the first' do
      expect(render(home, '<r:children:each status="published" by="title"><r:unless_first>, </r:unless_first><r:title /></r:children:each>'))
        .to eq('Apple, Banana, Cherry')
    end

    it 'renders <r:if_last> only for the last child' do
      expect(render(home, '<r:children:each status="published" by="title"><r:title /><r:if_last>[last]</r:if_last> </r:children:each>'))
        .to eq('Apple Banana Cherry[last] ')
    end

    it 'renders <r:unless_last> for every child but the last' do
      expect(render(home, '<r:children:each status="published" by="title"><r:title /><r:unless_last>, </r:unless_last></r:children:each>'))
        .to eq('Apple, Banana, Cherry')
    end

    it 'renders a header only when it changes' do
      # A constant header renders once (before the first child) then is suppressed.
      expect(render(home, '<r:children:each status="published" by="title"><r:header>H</r:header><r:title /> </r:children:each>'))
        .to eq('HApple Banana Cherry ')
    end
  end

  describe '<r:children:first> and <r:children:last>' do
    it 'renders the first child (by published_at)' do
      expect(render(home, '<r:children:first status="published"><r:title /></r:children:first>')).to eq('Apple')
    end

    it 'renders the last child (by published_at)' do
      expect(render(home, '<r:children:last status="published"><r:title /></r:children:last>')).to eq('Cherry')
    end

    it 'respects ordering options when picking the first child' do
      expect(render(home, '<r:children:first status="published" by="title" order="desc"><r:title /></r:children:first>')).to eq('Cherry')
    end
  end

  describe 'pagination' do
    # The pagination *controls* are rendered by the will_paginate view helper,
    # which needs a view context that a model-level parse does not have, so we
    # stub that layer and assert the results-slicing behavior of the tag.
    before do
      allow(home).to receive(:will_paginate).and_return('[controls]')
      allow(home).to receive(:will_paginate_options).and_return({})
    end

    it 'renders only the current page of children plus pagination controls' do
      home.pagination_parameters = { page: 1, per_page: 2 }
      expect(render(home, '<r:children:each status="published" by="title" paginated="true" per_page="2"><r:title /> </r:children:each>'))
        .to eq('Apple Banana [controls]')
    end

    it 'renders the second page of children' do
      home.pagination_parameters = { page: 2, per_page: 2 }
      expect(render(home, '<r:children:each status="published" by="title" paginated="true" per_page="2"><r:title /> </r:children:each>'))
        .to eq('Cherry [controls]')
    end

    it 'renders nothing for the standalone pagination tag when there is no paginated list' do
      expect(render(home, '<r:pagination />')).to eq('')
    end
  end
end
