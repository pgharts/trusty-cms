module UrlHelper
  def default_route?(page)
    page_class_name = page.class.name
    page_class_name == 'Page' || (defined?(DEFAULT_PAGE_TYPE_ROUTES) && DEFAULT_PAGE_TYPE_ROUTES.include?(page_class_name))
  end

  def lookup_custom_page_path(page)
    return nil unless defined?(CUSTOM_PAGE_TYPE_ROUTES) && CUSTOM_PAGE_TYPE_ROUTES.is_a?(Hash)

    CUSTOM_PAGE_TYPE_ROUTES[page.class.name.to_sym]
  end
end
