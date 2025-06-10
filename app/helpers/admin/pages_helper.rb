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
    parent_pages = []
    parent_pages.concat(Page.parent_pages(current_site.homepage_id))
    parent_pages << page.parent if page.parent
    selected_page_id = page.parent_id
    options_for_select(parent_pages.map { |p| [p.title, p.id] }, selected_page_id)
  end
end
