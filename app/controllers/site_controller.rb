require 'trusty_cms/pagination/controller'
require 'will_paginate/array'

class SiteController < ApplicationController
  include TrustyCms::Pagination::Controller

  #  no_login_required
  skip_before_action :authenticate_user!

  def self.cache_timeout=(val)
    TrustyCms::PageResponseCacheDirector.cache_timeout = val
  end

  def self.cache_timeout
    TrustyCms::PageResponseCacheDirector.cache_timeout
  end

  def show_page
    url = params[:url]
    url = if Array === url
            url.join('/')
          else
            url.to_s
          end
    if @page = find_page(url)
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
      render template: 'site/not_found', status: 404, layout: false
    end
  rescue Page::MissingRootPageError
    redirect_to welcome_path
  end

  def cacheable_request?
    (request.head? || request.get?) && !Rails.env.development?
  end

  # hide_action :cacheable_request?

  def set_expiry(time, options = {})
    expires_in time, options
  end

  # hide_action :set_expiry

  def set_etag(val)
    headers['ETag'] = val
  end

  # hide_action :set_expiry

  private

  def set_cache_control
    response_cache_director(@page).set_cache_control
  end

  def response_cache_director(page)
    klass_name = "TrustyCms::#{page.class}ResponseCacheDirector"
    begin
      klass = klass_name.constantize
    rescue NameError, LoadError
      director_klass = 'TrustyCms::PageResponseCacheDirector'
      # Rubocop: The use of eval is a serious security risk.
      # eval(%Q{class #{klass_name} < #{director_klass}; end}, TOPLEVEL_BINDING)
      klass = director_klass.constantize
    end
    klass.new(page, self)
  end

  def find_page(url)
    Page.find_by_path(url, can_view_drafts?)
  end

  def process_page(page)
    page.pagination_parameters = pagination_parameters
    page.process(request, response)
  end

  def can_view_drafts?
    user_signed_in? && (current_user[:admin] || current_user[:designer] || current_user[:content_editor])
  end
end
