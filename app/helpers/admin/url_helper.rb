module Admin::UrlHelper
  require 'uri'

  def generate_page_url(url, page)
    base_url = extract_base_url(url)
    build_url(base_url, page)
  end

  def build_url(base_url, page)
    return "#{base_url}#{page.path}" if default_route?(page)

    path = lookup_page_path(page)
    return nil unless path

    "#{base_url}/#{path}/#{page.slug}"
  end

  def extract_base_url(url)
    uri = URI.parse(url)
    host = uri.host
    scheme = uri.scheme
    return "#{scheme}://#{host}:#{uri.port}" if host&.include?('localhost')

    "#{scheme}://#{host}"
  end

  def default_route?(page)
    page.class.name == 'Page' || (defined?(DEFAULT_PAGE_TYPES_ROUTES) && DEFAULT_PAGE_TYPES_ROUTES.include?(page.class.name))
  end

  def lookup_page_path(page)
    return nil unless defined?(CUSTOM_PAGE_TYPE_ROUTES) && CUSTOM_PAGE_TYPE_ROUTES.is_a?(Hash)

    CUSTOM_PAGE_TYPE_ROUTES[page.class.name.to_sym]
  end
end
