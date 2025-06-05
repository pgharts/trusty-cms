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
    
      user_id = version.whodunnit.to_i
      user = User.find_by(id: user_id)
      user_name = user&.name || 'Unknown User'
    
      {
        action: version.event.titleize,
        page_title: page.title,
        page_url: "/admin/pages/#{page.id}",
        updated_at: version.created_at.strftime("%A, %B %d, %I:%M %p"),
        user_name: user_name
      }
    end
  end

  private

  def initialize_variables
    @user            = current_user
    @controller_name = 'changes'
    @template_name   = 'show'
  end
end
