module Admin::PagesHelper
  include Admin::NodeHelper
  include Admin::ReferencesHelper

  def class_of_page
    @page.class
  end

  def filter
    @page.parts.first.filter if @page.parts.respond_to?(:any?) && @page.parts.any?
  end

  def meta_errors?
    !!(@page.errors[:slug] or @page.errors[:breadcrumb])
  end

  def clean_page_description(page)
    page.description.to_s.strip.gsub(/\t/, '').gsub(/\s+/, ' ')
  end

  def parent_page_options(current_site, page)
    parent_pages = Page.parent_pages(current_site.homepage_id).to_a
    parent_pages << page.parent if page.parent && parent_pages.exclude?(page.parent)
    # A page can never be its own parent. For a site's root page this would
    # otherwise set parent_id to itself and create an infinite loop in the tree.
    parent_pages.reject! { |p| p.id == page.id }
    # The root (top) page of a site must have no parent, so give it a blank
    # option. Without one the browser submits the first option on save, which
    # gives the root page a parent and breaks the whole site.
    return options_for_select([[t('select.none'), '']], '') if root_page?(current_site, page)

    options = parent_pages.map { |p| [p.title, p.id] }
    options_for_select(options, page.parent.id)
  end

  def root_page?(current_site, page)
    page.id.present? && page.id == current_site.homepage_id
  end

  def revert_confirmation_message(version)
    date = version[:update_date]
    time = version[:update_time]
    "Are you sure you want to revert the page to the version before the change made on #{date} at #{time}? All changes made after that will be lost."
  end
end
