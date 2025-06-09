require 'diffy'
require 'nokogiri'

class Admin::ChangesController < Admin::ResourceController
  before_action :initialize_variables

  def show
    site_id = current_site.id
    recent_versions = PaperTrail::Version
      .where(item_type: 'Page')
      .joins("INNER JOIN pages ON pages.id = versions.item_id")
      .where(pages: { site_id: site_id })
      .where("versions.created_at >= ?", 1.month.ago)
      .order("versions.created_at DESC")
      .limit(50)

    @recent_changes = recent_versions.map do |version|
      page = Page.find(version.item_id)
      user = User.find_by(id: version.whodunnit.to_i)
      user_name = user&.name || 'Unknown User'
      transaction_id = version.transaction_id

      changes = PaperTrail::Version.where(transaction_id: transaction_id)

      diffs = changes.map { |v| diffy_diff_content(v) }.compact
      diff_text = diffs.any? ? diffs.join("<br><br>") : nil

      {
        action: version.event.titleize,
        diff: diff_text,
        page_title: page.title,
        page_url: "/admin/pages/#{page.id}",
        updated_at: version.created_at.strftime("%A, %B %d, %I:%M %p"),
        user_name: user_name
      }
    end
  end

  private

  def diffy_diff_content(version)
    return unless version.changeset.key?('content')

    old_html, new_html = version.changeset['content']
    return nil if old_html == new_html

    label = case version.item_type
            when 'Page' then 'Page Content'
            when 'PagePart'
              part = PagePart.find_by(id: version.item_id)
              part ? "Part: #{part.name.titleize}" : 'Unnamed Part'
            else
              version.item_type
            end
    
    diff_html = Diffy::Diff.new(old_html, new_html, context: 1).to_s(:html)

    "<h2>#{label.titleize}</h2><div class=\"diffy-output\">#{diff_html}</div>"
  end

  def strip_html(html)
    Nokogiri::HTML(html.to_s).text.strip
  end

  def initialize_variables
    @user            = current_user
    @controller_name = 'changes'
    @template_name   = 'show'
  end
end
