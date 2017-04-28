require 'trusty_cms/pagination/controller'
class SiteController < ApplicationController
  include TrustyCms::Pagination::Controller

  skip_before_action :verify_authenticity_token
  no_login_required

  def self.cache_timeout=(val)
    TrustyCms::PageResponseCacheDirector.cache_timeout=(val)
  end
  def self.cache_timeout
    TrustyCms::PageResponseCacheDirector.cache_timeout
  end

  def show_page
    url = params[:url]
    if Array === url
      url = url.join('/')
    else
      url = url.to_s
    end
    if @page = find_page(url)
      batch_page_status_refresh if (url == "/" || url == "")
      # This is a bit of a hack to get Vanity URL pages working in another extension
      # In Rails 2, redirect_to halted execution, so process_page could be aliased and
      # a redirect could be used. This no longer works. There's a better fix for this,
      # but for now, anything that aliases process_page can return false if it's rendering
      # or redirecting on its own.
      return unless process_page(@page)
      set_cache_control
      @performed_render ||= true
      render layout: false
    else
      render :template => 'site/not_found', :status => 404, layout: false
    end
  rescue Page::MissingRootPageError
    redirect_to welcome_path
  end

  def cacheable_request?
    (request.head? || request.get?) && live?
  end
  # hide_action :cacheable_request?

  def set_expiry(time, options={})
    expires_in time, options
  end
  # hide_action :set_expiry

  def set_etag(val)
    headers['ETag'] = val
  end
  # hide_action :set_expiry

  private
    def batch_page_status_refresh
      @changed_pages = []
      @pages = Page.where({:status_id => Status[:scheduled].id})
      @pages.each do |page|
        if page.published_at <= Time.now
           page.status_id = Status[:published].id
           page.save
           @changed_pages << page.id
        end
      end

      expires_in nil, :private=>true, "no-cache" => true if @changed_pages.length > 0
    end

    def set_cache_control
      response_cache_director(@page).set_cache_control
    end

    def response_cache_director(page)
      klass_name = "TrustyCms::#{page.class}ResponseCacheDirector"
      begin
        klass = klass_name.constantize
      rescue NameError, LoadError
        director_klass = "TrustyCms::PageResponseCacheDirector"
        #Rubocop: The use of eval is a serious security risk.
        #eval(%Q{class #{klass_name} < #{director_klass}; end}, TOPLEVEL_BINDING)
        klass = director_klass.constantize
      end
      klass.new(page, self)
    end

    def find_page(url)
      found = Page.find_by_path(url, live?)
      found if found and (found.published? or dev?)
    end

    def process_page(page)
      page.pagination_parameters = pagination_parameters
      page.process(request, response)
    end

    def dev?
      request.host == @trusty_config['dev.host'] || request.host =~ /^dev\./
    end

    def live?
      not dev?
    end
end
