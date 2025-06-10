require 'diffy'

class Admin::ChangesController < Admin::ResourceController
  before_action :initialize_variables

  def show
    @changes = load_changes
    @change_error = 'Version ID not found.' if params[:version_id].present? && @changes.empty?
  end

  private

  def load_changes
    return load_single_change if params[:version_id].present?

    load_recent_changes
  end

  def load_single_change
    version = PaperTrail::Version.find_by(id: params[:version_id])
    version ? [build_change_entry(version)] : []
  end

  def load_recent_changes
    fetch_recent_page_versions.map { |version| build_change_entry(version) }
  end

  def fetch_recent_page_versions
    PaperTrail::Version
      .where(item_type: 'Page')
      .joins('INNER JOIN pages ON pages.id = versions.item_id')
      .where(pages: { site_id: current_site.id })
      .where('versions.created_at >= ?', 1.month.ago)
      .order(created_at: :desc)
      .limit(25)
  end

  def build_change_entry(version)
    page = Page.find_by(id: version.item_id)
    return {} unless page

    {
      action: version.event.titleize,
      diff: build_diff(version),
      id: version.id,
      page_title: page.title,
      page_url: admin_page_url(page),
      updated_at: format_timestamp(version.created_at),
      user_name: user_name(version.whodunnit),
    }
  end

  def build_diff(version)
    related_versions = PaperTrail::Version.where(transaction_id: version.transaction_id)
    diffs = related_versions.flat_map { |v| diff_fields(v) }.compact
    diffs.any? ? diffs.join('<br />') : nil
  end

  def diff_fields(version)
    label = label_for_version(version)

    version.changeset.map do |field, (old_val, new_val)|
      next unless renderable_diff?(field, old_val, new_val)

      render_field_diff(version, field, old_val, new_val, label)
    end
  end

  def renderable_diff?(field, old_val, new_val)
    !ignored_fields.include?(field) && !(old_val.nil? && new_val == '')
  end

  def render_field_diff(version, field, old_val, new_val, label)
    diff_html = Diffy::Diff.new(old_val, new_val, context: 1).to_s(:html)
    display_label = version.item_type == 'Page' ? field : label
    "<h2>#{display_label.humanize.titleize}</h2>#{diff_html}"
  end

  def skip_field_diff?(field, old_val, new_val)
    ignored_fields.include?(field) || (old_val.nil? && new_val == '')
  end

  def ignored_fields
    %w[
      created_at
      created_by_id
      id
      lock_version
      name
      page_id
      published_at
      updated_at
      updated_by_id
    ].freeze
  end

  def user_name(whodunnit)
    user_id = Integer(whodunnit, exception: false)
    User.find_by(id: user_id)&.name || 'Unknown User'
  end

  def label_for_version(version)
    case version.item_type
    when 'PagePart' then PagePart.find_by(id: version.item_id)&.name || 'Unknown PagePart'
    when 'PageField' then PageField.find_by(id: version.item_id)&.name || 'Unknown PageField'
    else version.item_type
    end
  end

  def format_timestamp(timestamp)
    timestamp.strftime('%A, %B %d, %I:%M %p')
  end

  def admin_page_url(page)
    "/admin/pages/#{page.id}"
  end

  def initialize_variables
    @user = current_user
    @controller_name = 'changes'
    @template_name = 'show'
  end
end
