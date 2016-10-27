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

  def status_to_display
    @page.status_id = 100 if @page.status_id == 90
    @display_status = Status.selectable.map{ |s| [I18n.translate(s.name.downcase), s.id] }
  end

  def clean_page_description(page)
    page.description.to_s.strip.gsub(/\t/,'').gsub(/\s+/,' ')
  end
end
