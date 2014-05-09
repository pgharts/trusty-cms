class ConfigDataset < Dataset::Base
  def load
    # Simulates the defaults on bootstrapped TrustyCms instances
    TrustyCms::Config['admin.title'] = 'TrustyCms CMS'
    TrustyCms::Config['admin.subtitle'] = 'Publishing for Small Teams'
    TrustyCms::Config['defaults.page.parts'] = 'body, extended'
    TrustyCms::Config['defaults.page.status'] = 'Draft'
    TrustyCms::Config['defaults.page.filter'] = nil
    TrustyCms::Config['defaults.page.fields'] = 'Keywords, Description'
    TrustyCms::Config['defaults.snippet.filter'] = nil
    TrustyCms::Config['session_timeout'] = 2.weeks
    TrustyCms::Config['default_locale'] = 'en'
  end
end
