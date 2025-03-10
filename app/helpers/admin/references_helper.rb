require 'RedCloth'

module Admin::ReferencesHelper
  def tag_reference
    String.new.tap do |output|
      class_of_page.tag_descriptions.sort.each do |tag_name, description|
        value = t("desc.#{tag_name.gsub(':', '-')}").match('desc') ? description : t("desc.#{tag_name.gsub(':', '-')}")
        output << render(partial: 'admin/references/tag_reference',
                         locals: { tag_name: tag_name,
                                   description: RedCloth.new(TrustyCms::Taggable::Util.strip_leading_whitespace(value)).to_html })
      end
    end
  end

  def filter_reference
    if filter.blank?
      'There is no filter on the current page part.'
    else
      if filter.description.blank?
        'There is no documentation on this filter.'
      else
        filter.description
      end
    end
  end

  def _display_name
    case params[:type]
    when 'filters'
      filter ? filter.filter_name : t('select.none')
    when 'tags'
      class_of_page.display_name
    end
  end

  def filter
    @filter ||= begin
                  TextFilter.find_descendant(params[:filter_name])
                end
  end

  def class_of_page
    @page_class ||= (params[:class_name].blank? ? 'Page' : params[:class_name]).constantize
  end
end
