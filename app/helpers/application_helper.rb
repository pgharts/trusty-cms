module ApplicationHelper
  include Admin::RegionsHelper
  include Admin::UrlHelper

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
    model.new_record? ? t('creating_status', model: t(model.class.name.downcase)) : "#{I18n.t('saving_changes')}&#8230;"
  end

  def save_model_button(model, options = {})
    model_name = model.class.name.underscore
    human_model_name = model_name.humanize.titlecase
    options[:label] ||= model.new_record? ?
      t('buttons.create', name: t(model_name, default: human_model_name), default: 'Create ' + human_model_name) :
      t('buttons.save_changes', default: 'Save Changes')
    options[:class] ||= 'button'
    options[:accesskey] ||= 'S'
    options[:id] ||= 'save-button'
    submit_tag options.delete(:label), options
  end

  def save_model_and_continue_editing_button(_model)
    submit_tag t('buttons.save_and_continue'), name: 'continue', class: 'button', accesskey: 's', id: 'save-and-continue-button'
  end

  def current_item?(item)
    if item.tab&.many? { |i| current_url?(i.relative_url) }
      # Accept only stricter URL matches if more than one matches
      current_page?(item.url)
    else
      current_url?(item.relative_url)
    end
  end

  def current_tab?(tab)
    @current_tab ||= tab if tab.any? { |item| current_url?(item.relative_url) }
    @current_tab == tab
  end

  def current_url?(options)
    url = case options
          when Hash
            url_for options
          else
            options.to_s
          end
    request.original_fullpath =~ Regexp.new('^' + Regexp.quote(clean(url)))
  end

  def clean(url)
    uri = URI.parse(url)
    uri.path.gsub(%r{/+}, '/').gsub(%r{/$}, '')
  end

  def admin?
    current_user&.admin?
  end

  def designer?
    current_user and (current_user.designer? or current_user.admin?)
  end

  def updated_stamp(model)
    unless model.new_record?
      updated_by = (model.updated_by || model.created_by)
      name = updated_by ? updated_by.name : nil
      time = (model.updated_at || model.created_at)
      if name || time
        html = %{<div class="updated_line">#{t('timestamp.last_updated')} }
        html << %{#{t('timestamp.by')} <strong>#{name}</strong> } if name
        html << %{#{t('timestamp.at')} #{timestamp(time)}} if time
        html << %{</div>}
        html.html_safe
      end
    end
  end

  def timestamp(time)
    # time.strftime("%I:%M %p on %B %e, %Y").sub("AM", 'am').sub("PM", 'pm')
    I18n.localize(time, format: :timestamp)
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
    t(name.underscore.downcase, default: name)
  end

  def available_locales_select
    [[t('select.default'), '']] + TrustyCms::AvailableLocales.locales
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

  # returns the usual set of pagination links.
  # options are passed through to will_paginate
  # and a 'show all' depagination link is added if relevant.
  def pagination_for(list, options = {})
    if list.respond_to? :total_pages
      options = {
        max_per_page: @trusty_config['pagination.max_per_page'] || 500,
        depaginate: true,
      }.merge(options.symbolize_keys)
      depaginate = options.delete(:depaginate)                                     # supply :depaginate => false to omit the 'show all' link
      depagination_limit = options.delete(:max_per_page)                           # supply :max_per_page => false to include the 'show all' link no matter how large the collection
      html = will_paginate(list, will_paginate_options.merge(options))
      if depaginate && list.total_pages > 1 && (!depagination_limit.blank? || list.total_entries <= depagination_limit.to_i)
        html << content_tag(:div, link_to(t('show_all'), pp: 'all'), class: 'depaginate')
      elsif depaginate && list.total_entries > depagination_limit.to_i
        html = content_tag(:div, link_to('paginate', p: 1), class: 'pagination')
      end
      html
    end
  end

  private

  def append_image_extension(name)
    if name =~ /\.(.*?)$/
      name
    else
      name + '.png'
      end
  end
end
