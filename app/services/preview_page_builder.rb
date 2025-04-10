class PreviewPageBuilder
  def initialize(model_class:, page_params:, referer:)
    @model_class = model_class
    @page_params = page_params
    @referer = referer
  end

  def build
    editing_existing_page? ? build_existing_page : build_new_page
  end

  private

  def build_existing_page
    page = find_page_from_referer.becomes(valid_model_class)
    page.update(@page_params)
    page
  end

  def build_new_page
    page = valid_model_class.new(@page_params)

    if creating_child_page?
      parent = find_page_from_referer
      page.parent = parent
      page.layout_id ||= parent.layout_id
    end

    page.save!
    page
  end

  def valid_model_class
    Page.descendants.include?(@model_class) ? @model_class : Page
  end

  def find_page_from_referer
    Page.find(extract_page_id_from_referer)
  end

  def extract_page_id_from_referer
    @referer[%r{/admin/pages/(\d+)}, 1]
  end

  def editing_existing_page?
    @referer =~ %r{/admin/pages/\d+/edit}
  end

  def creating_child_page?
    @referer =~ %r{/admin/pages/\d+/children/new}
  end
end
