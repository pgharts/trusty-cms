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
    PAGE_TYPES[page.class.name.to_sym]
  end

  PAGE_TYPES = {
    BlogPage: 'blog',
    DonationPage: 'donate',
    ExhibitionPage: 'exhibit',
    FlexPackagePage: 'flex_package',
    MembershipPage: 'membership',
    MultiViewPage: 'multiview',
    NonTicketedEventPage: 'event',
    PersonPage: 'biography',
    ProductionPage: 'production',
    RegistrationEventPage: 'registration',
    SimpleDonationPage: 'donationfeed',
  }.freeze
end
