module Admin::UrlHelper
  require 'uri'

  def build_url(base_url, page)
    if page.class.name == 'Page'
      "#{base_url}#{page.path}"
    else
      path = lookup_page_path(page)
      path ? "#{base_url}/#{path}/#{page.slug}" : nil
    end
  end

  def extract_base_url(url)
    uri = URI.parse(url)
    host = uri.host
    scheme = uri.scheme
    return "#{scheme}://#{host}:#{uri.port}" if host&.include?('localhost')

    "#{scheme}://#{host}"
  end

  def generate_page_url(url, page)
    base_url = extract_base_url(url)
    build_url(base_url, page)
  end

  def lookup_page_path(page)
    # Use the globally defined PAGE_TYPE_ROUTES from the parent application
    return nil unless defined?(PAGE_TYPE_ROUTES) && PAGE_TYPE_ROUTES.is_a?(Hash)

    PAGE_TYPE_ROUTES[page.class.name.to_sym]
  end
end
