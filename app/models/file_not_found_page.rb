class FileNotFoundPage < Page
  def cache_timeout
    5.minutes
  end

  def allowed_children
    []
  end

  description %{
    A "File Not Found" page can be used to override the default error
    page in the event that a page is not found among a page's children.

    To create a "File Not Found" error page for an entire Web site, create
    a page that is a child of the root page and assign it "File Not Found"
    page type.
  }

  tag 'attempted_url' do |_tag|
    CGI.escapeHTML(request.request_uri) unless request.nil?
  end

  def virtual?
    true
  end

  def response_code
    404
  end
end
