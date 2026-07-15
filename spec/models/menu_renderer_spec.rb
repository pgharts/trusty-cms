require 'spec_helper'

describe MenuRenderer do
  # MenuRenderer is extended onto a Page instance (see Admin::NodeHelper).
  let(:page) { Page.new.tap { |p| p.extend(MenuRenderer) } }

  # MenuRenderer keeps its exclusion list in a module-level ivar. Isolate it so
  # the .exclude example doesn't leak into others regardless of run order.
  before(:all) { @orig_excluded = MenuRenderer.instance_variable_get(:@excluded_class_names) }
  after(:all)  { MenuRenderer.instance_variable_set(:@excluded_class_names, @orig_excluded) }
  before       { MenuRenderer.instance_variable_set(:@excluded_class_names, []) }

  describe '#view' do
    it 'reads back an assigned view' do
      view = Object.new
      page.view = view
      expect(page.view).to eq(view)
    end
  end

  describe '#menu_renderer_module_name' do
    it 'is MenuRenderer for a plain page' do
      expect(page.menu_renderer_module_name).to eq('MenuRenderer')
    end
  end

  describe '#additional_menu_features?' do
    it 'is false when no page-specific renderer module exists' do
      expect(page.additional_menu_features?).to be_falsey
    end
  end

  describe '#allowed_child_classes' do
    it 'constantizes the names from the allowed-children cache' do
      page.allowed_children_cache = 'Page,FileNotFoundPage'
      expect(page.allowed_child_classes).to eq([Page, FileNotFoundPage])
    end

    it 'skips names that cannot be constantized' do
      page.allowed_children_cache = 'Page,NotARealClassName'
      expect(page.allowed_child_classes).to eq([Page])
    end

    it 'excludes names registered via .exclude' do
      MenuRenderer.exclude('FileNotFoundPage')
      page.allowed_children_cache = 'Page,FileNotFoundPage'
      expect(page.allowed_child_classes).to eq([Page])
      expect(MenuRenderer.excluded_class_names).to include('FileNotFoundPage')
    end
  end

  describe '#add_child_disabled?' do
    it 'is true when there are no allowed child classes' do
      page.allowed_children_cache = ''
      expect(page.add_child_disabled?).to be(true)
    end

    it 'is false when there is at least one allowed child class' do
      page.allowed_children_cache = 'Page'
      expect(page.add_child_disabled?).to be(false)
    end
  end
end
