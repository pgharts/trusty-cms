require 'diffy'

class Admin::ChangesController < Admin::ResourceController
  before_action :initialize_variables

  def show
    @changes =
      if params[:version_id].present?
        version = PaperTrail::Version.find_by(id: params[:version_id])
        version ? [build_change_entry(version)] : []
      else
        fetch_recent_page_versions.map { |version| build_change_entry(version) }
      end

    @change_error = "Version ID not found." if params[:version_id].present? && @changes.empty?
  end

  private

  def fetch_recent_page_versions
    PaperTrail::Version
      .where(item_type: 'Page')
      .joins("INNER JOIN pages ON pages.id = versions.item_id")
      .where(pages: { site_id: current_site.id })
      .where("versions.created_at >= ?", 1.month.ago)
      .order(created_at: :desc)
      .limit(25)
  end

  def build_change_entry(version)
    page = Page.find_by(id: version.item_id)
    return {} unless page

    user_id = Integer(version.whodunnit, exception: false)
    user_name = User.find_by(id: user_id)&.name || 'Unknown User'

    changes = PaperTrail::Version.where(transaction_id: version.transaction_id)
    diffs = changes.flat_map { |v| diff_content(v) }.compact
    diff_text = diffs.any? ? diffs.join('<br />') : nil

    {
      action: version.event.titleize,
      diff: diff_text,
      id: version.id,
      page_title: page.title,
      page_url: "/admin/pages/#{page.id}",
      updated_at: version.created_at.strftime("%A, %B %d, %I:%M %p"),
      user_name: user_name
    }
  end

  def diff_content(version)
    label = label_for_version(version)

    version.changeset.map do |field, (old_val, new_val)|
      next if ignored_field?(field)
      next if old_val.nil? && new_val == ''

      diff_html = Diffy::Diff.new(old_val, new_val, context: 1).to_s(:html)
      display_label = (version.item_type == 'Page') ? field : label

      "<h2>#{display_label.humanize.titleize}</h2>#{diff_html}"
    end
  end

  def label_for_version(version)
    case version.item_type
    when 'PagePart'
      PagePart.find_by(id: version.item_id)&.name || 'Unknown PagePart'
    when 'PageField'
      PageField.find_by(id: version.item_id)&.name || 'Unknown PageField'
    else
      version.item_type
    end
  end

  def ignored_field?(field)
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
    ].include?(field)
  end

  def initialize_variables
    @user = current_user
    @controller_name = 'changes'
    @template_name = 'show'
  end
end
