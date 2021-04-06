module Admin::ConfigurationHelper
  # Defines helper methods for use in the admin interface when displaying or editing configuration.

  # Renders the setting as label and value:
  #
  #   show_config("admin.title")
  #   => <label for="admin_title">Admin title<label><span id="admin_title">TrustyCms CMS</span>
  #
  def show_config(key, options = {})
    setting = setting_for(key)
    setting.valid?
    domkey = key.gsub(/\W/, '_')
    html = ''
    html << content_tag(:label, t("trusty_config.#{key}").titlecase, for: domkey)
    if setting.boolean?
      value = setting.checked? ? t('yes') : t('no')
      html << content_tag(:span, value, id: domkey, class: "#{value} #{options[:class]}")
    else
      value = setting.selected_value || setting.value
      html << content_tag(:span, value, id: domkey, class: options[:class])
    end
    html << content_tag(:span, " #{t("units.#{setting.units}")}", class: 'units') if setting.units
    html << content_tag(:span, " #{t('warning')}: #{[setting.errors[:value]].flatten.first}", class: 'warning') if setting.errors.messages[:value].present?
    Rails.logger.error(html)
    html.html_safe
  end

  # Renders the setting as label and appropriate input field:
  #
  #   edit_setting("admin.title")
  #   => <label for="admin_title">Admin title<label><input type="text" name="config['admin.title']" id="admin_title" value="TrustyCms CMS" />
  #
  #   edit_config("defaults.page.status")
  #   =>
  #   <label for="defaults_page_status">Default page status<label>
  #   <select type="text" name="config['defaults.page.status']" id="defaults_page_status">
  #     <option value="Draft">Draft</option>
  #     ...
  #   </select>
  #
  #   edit_setting("user.allow_password_reset?")
  #   => <label for="user_allow_password_reset_">Admin title<label><input type="checkbox" name="config['user.allow_password_reset?']" id="user_allow_password_reset_" value="1" checked="checked" />
  #
  def edit_config(key, _options = {})
    setting = setting_for(key)
    domkey = key.gsub(/\W/, '_')
    name = "trusty_config[#{key}]"
    title = t("trusty_config.#{key}").titlecase
    title << content_tag(:span, " (#{t("units.#{setting.units}")})", class: 'units') if setting.units
    value = params[key.to_sym].nil? ? setting.value : params[key.to_sym]
    html = ''
    if setting.boolean?
      html << hidden_field_tag(name, 0)
      html << check_box_tag(name, 1, value, class: 'setting', id: domkey)
      html << content_tag(:label, title.html_safe, class: 'checkbox', for: domkey)
    elsif setting.selector?
      html << content_tag(:label, title.html_safe, for: domkey)
      html << select_tag(name, options_for_select(setting.definition.selection, value), class: 'setting', id: domkey)
    else
      html << content_tag(:label, title.html_safe, for: domkey)
      html << text_field_tag(name, value, class: 'textbox', id: domkey)
    end
    if setting.errors[:value].present?
      html << content_tag(:span, [setting.errors[:value]].flatten.first, class: 'error')
      html = content_tag(:span, html.html_safe, class: 'error-with-field')
    end
    html.html_safe
  end

  def setting_for(key)
    @trusty_config ||= {} # normally initialized in Admin::ConfigurationController
    @trusty_config[key] ||= TrustyCms.config.find_or_initialize_by(key: key)
  end

  def definition_for(key)
    if setting = setting_for(key)
      setting.definition
    end
  end
end
