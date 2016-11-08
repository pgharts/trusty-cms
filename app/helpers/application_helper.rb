module ApplicationHelper
  include Admin::RegionsHelper

  def trusty_config
    TrustyCms::Config
  end

  def default_page_title
    title + ' - ' + subtitle
  end

  def title
    trusty_config['admin.title'] || 'Trusty CMS'
  end

  def subtitle
    trusty_config['admin.subtitle'] || 'Publishing for Small Teams'
  end

  def logged_in?
    !current_user.nil?
  end

  def onsubmit_status(model)
    model.new_record? ? t('creating_status', :model => t(model.class.name.downcase)) : "#{I18n.t('saving_changes')}&#8230;"
  end

  def save_model_button(model, options = {})
    model_name = model.class.name.underscore
    human_model_name = model_name.humanize.titlecase
    options[:label] ||= model.new_record? ?
      t('buttons.create', :name => t(model_name, :default => human_model_name), :default => 'Create ' + human_model_name) :
      t('buttons.save_changes', :default => 'Save Changes')
    options[:class] ||= "button"
    options[:accesskey] ||= 'S'
    submit_tag options.delete(:label), options
  end

  def save_model_and_continue_editing_button(model)
    submit_tag t('buttons.save_and_continue'), :name => 'continue', :class => 'button', :accesskey => "s"
  end

  def current_item?(item)
    if item.tab && item.tab.many? {|i| current_url?(i.relative_url) }
      # Accept only stricter URL matches if more than one matches
      current_page?(item.url)
    else
      current_url?(item.relative_url)
    end
  end

  def current_tab?(tab)
    @current_tab ||= tab if tab.any? {|item| current_url?(item.relative_url) }
    @current_tab == tab
  end

  def current_url?(options)
    url = case options
          when Hash
            url_for options
          else
            options.to_s
          end
    #TODO: look for other instances of request_uri
    request.original_fullpath =~ Regexp.new('^' + Regexp.quote(clean(url)))
  end

  def clean(url)
    uri = URI.parse(url)
    uri.path.gsub(%r{/+}, '/').gsub(%r{/$}, '')
  end

  def admin?
    current_user and current_user.admin?
  end

  def designer?
    current_user and (current_user.designer? or current_user.admin?)
  end

  def updated_stamp(model)
    unless model.new_record?
      updated_by = (model.updated_by || model.created_by)
      name = updated_by ? updated_by.name : nil
      time = (model.updated_at || model.created_at)
      if name or time
        html = %{<p class="updated_line">#{t('timestamp.last_updated')} }
        html << %{#{t('timestamp.by')} <strong>#{name}</strong> } if name
        html << %{#{t('timestamp.at')} #{timestamp(time)}} if time
        html << %{</p>}
        html.html_safe
      end
    end
  end

  def timestamp(time)
    # time.strftime("%I:%M %p on %B %e, %Y").sub("AM", 'am').sub("PM", 'pm')
    I18n.localize(time, :format => :timestamp)
  end

  def meta_errors?
    false
  end

  def meta_label
    meta_errors? ? 'Less' : 'More'
  end

  def image(name, options = {})
    image_tag(append_image_extension("admin/#{name}"), options)
  end

  def admin
    TrustyCms::AdminUI.instance
  end

  def body_classes
    @body_classes ||= []
  end

  def nav_tabs
    admin.nav
  end

  def translate_with_default(name)
    t(name.underscore.downcase, :default => name)
  end

  def available_locales_select
    [[t('select.default'),'']] + TrustyCms::AvailableLocales.locales
  end

  def stylesheet_overrides
    overrides = []
    if File.exist?("#{Rails.root}/public/stylesheets/admin/overrides.css") || File.exist?("#{Rails.root}/public/stylesheets/sass/admin/overrides.sass")
      overrides << 'admin/overrides'
    end
    overrides
  end

  def javascript_overrides
    overrides = []
    if File.exist?("#{Rails.root}/public/javascripts/admin/overrides.js")
      overrides << 'admin/overrides'
    end
    overrides
  end

  # Returns a Gravatar URL associated with the email parameter.
  # See: http://douglasfshearer.com/blog/gravatar-for-ruby-and-ruby-on-rails
  def gravatar_url(email, options={})
    # Default to highest rating. Rating can be one of G, PG, R X.
    options[:rating] ||= "G"

    # Default size of the image.
    options[:size] ||= "32px"

    # Default image url to be used when no gravatar is found
    # or when an image exceeds the rating parameter.
    local_avatar_url = "/production/assets/admin/avatar_#{([options[:size].to_i] * 2).join('x')}.png"
    default_avatar_url = "#{request.protocol}#{request.host_with_port}#{ActionController::Base.relative_url_root}#{local_avatar_url}"
    options[:default] ||= default_avatar_url

    unless email.blank?
      # Build the Gravatar url.
      url = '//gravatar.com/avatar/'
      url << "#{Digest::MD5.new.update(email)}?"
      url << "rating=#{options[:rating]}" if options[:rating]
      url << "&size=#{options[:size]}" if options[:size]
      url << "&default=#{options[:default]}" if options[:default]
      # Test the Gravatar url
      require 'open-uri'
      begin; open "http:#{url}", :proxy => true
      rescue; local_avatar_url
      else; url
      end
    else
      local_avatar_url
    end
  end

  # returns the usual set of pagination links.
  # options are passed through to will_paginate
  # and a 'show all' depagination link is added if relevant.
  def pagination_for(list, options={})
    if list.respond_to? :total_pages
      options = {
        :max_per_page => @trusty_config['pagination.max_per_page'] || 500,
        :depaginate => true
      }.merge(options.symbolize_keys)
      depaginate = options.delete(:depaginate)                                     # supply :depaginate => false to omit the 'show all' link
      depagination_limit = options.delete(:max_per_page)                           # supply :max_per_page => false to include the 'show all' link no matter how large the collection
      html = will_paginate(list, will_paginate_options.merge(options))
      if depaginate && list.total_pages > 1 && (!depagination_limit.blank? || list.total_entries <= depagination_limit.to_i)
        html << content_tag(:div, link_to(t('show_all'), :pp => 'all'), :class => 'depaginate')
      elsif depaginate && list.total_entries > depagination_limit.to_i
        html = content_tag(:div, link_to("paginate", :p => 1), :class => 'pagination')
      end
      html
    end
  end

  private

    def append_image_extension(name)
      unless name =~ /\.(.*?)$/
        name + '.png'
      else
        name
      end
    end

end
