module Admin::NodeHelper

  def render_nodes(page, starting_index, parent_index = nil)
    @rendered_html = ""
    render_node page, starting_index, parent_index
    @rendered_html
  end

  def render_node(page, index, parent_index = nil)

    page.extend MenuRenderer
    page.view = self
    if page.additional_menu_features?
      page.extend(*page.menu_renderer_modules)
    end
    @current_node = page
    @rendered_html += (render :partial => 'admin/pages/node', :locals =>  {level: index,
                                                        index: index,
                                                        parent_index: parent_index,
                                                        page: page,
                                                        simple: false})
    if expanded
      current_index = index
      page.children.each do |child|
        child.becomes(child.class_name.constantize) if child.class_name.present?
        index = render_node child, index + 1, current_index
      end
    end

    index
  end

  def homepage
    @homepage ||= Page.find_by_parent_id(nil)
  end

  def show_all?
    controller.action_name == 'remove'
  end

  def expanded_rows
    unless @expanded_rows
      @expanded_rows = case
      when rows = cookies[:expanded_rows]
        rows.split(',').map { |x| Integer(x) rescue nil }.compact
      else
        []
      end

      if homepage and !@expanded_rows.include?(homepage.id)
        @expanded_rows << homepage.id
      end
    end
    @expanded_rows
  end

  def expanded
    show_all? || expanded_rows.include?(@current_node.id)
  end

  def padding_left(level)
    (level * 23) + 9
  end

  def children_class
    unless @current_node.children.empty?
      if expanded
        " children_visible"
      else
        " children_hidden"
      end
    else
      " no_children"
    end
  end

  def virtual_class
    @current_node.virtual? ? " virtual": ""
  end

  def expander(level)
    unless @current_node.children.empty? or level == 0
      image((expanded ? "collapse" : "expand"),
            :class => "expander", :alt => 'toggle children',
            :title => '')
    else
      ""
    end
  end

  def icon
    icon_name = @current_node.virtual? ? 'virtual_page' : 'page'
    image(icon_name, :class => "icon", :alt => '', :title => '')
  end

  def node_title
    %{<span class="title">#{ h(@current_node.title) }</span>}.html_safe
  end

  def page_type
    display_name = @current_node.class.display_name
    if display_name == 'Page'
      ""
    else
      %{<span class="info">(#{ h(display_name) })</span>}
    end
  end

  def spinner
    image('spinner.gif',
            :class => 'busy', :id => "busy_#{@current_node.id}",
            :alt => "",  :title => "",
            :style => 'display: none;')
  end
end
