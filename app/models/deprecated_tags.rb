require 'trusty_cms/taggable'
module DeprecatedTags
  include TrustyCms::Taggable

  deprecated_tag "comment", :substitute => "hide", :deadline => '2.0'

  deprecated_tag "meta", :deadline => '2.0' do |tag|
    if tag.double?
      tag.expand
    else
      tag.render('description', tag.attr) + tag.render('keywords', tag.attr)
    end
  end

  deprecated_tag "rfc1123_date", :deadline => '2.0' do |tag|
    page = tag.locals.page
    if date = page.published_at || page.created_at
      CGI.rfc1123_date(date.to_time)
    end
  end

end
