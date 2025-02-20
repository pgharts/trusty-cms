module Admin::UrlHelper
  require 'uri'

  def extract_base_url(url)
    uri = URI.parse(url)
    return "#{uri.scheme}://#{uri.host}:#{uri.port}" if uri.host&.include?('localhost')

    "#{uri.scheme}://#{uri.host}"
  end

  def generate_page_url(url, page)
    return unless page&.respond_to?(:slug)

    base_url = extract_base_url(url)

    if page.class.name == "Page"
      return "#{base_url}#{page.path}"
    else
      path = lookup_page_path(page)
      path ? "#{base_url}/#{path}/#{page.slug}" : nil
    end
  end

  def lookup_page_path(page)
    PAGE_TYPES[page.class.name.to_sym]
  end

  private

  PAGE_TYPES = {
    BlogPage: "blog",
    DonationPage: "donate",
    ExhibitionPage: "exhibit",
    FlexPackagePage: "flex_package",
    MembershipPage: "membership",
    MultiViewPage: "multiview",
    NonTicketedEventPage: "event",
    PackagePage: "package",
    PersonPage: 'biography',
    ProductionPage: "production",
    RegistrationEventPage: "registration",
    RenewalPage: "package/renewal",
    SimpleDonationPage: "donationfeed",
    SuperPackagePage: "super_package",
    TimedEntryPage: "timed-entry",
  }.freeze
end
