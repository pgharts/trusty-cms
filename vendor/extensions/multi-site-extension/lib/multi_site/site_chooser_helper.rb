module MultiSite::SiteChooserHelper

def sites_chooser_thing
  return "" unless admin? && defined?(Site) && defined?(controller) && controller.sited_model? && controller.template_name == 'index' && Site.several?
  options = Site.all.map{ |site| "<li>" + link_to( site.name, "#{request.path}?site_id=#{site.id}", :class => site == current_site ? 'fg' : '') + "</li>" }.join("")
  chooser = %{<div id="site_chooser">}
  #chooser << link_to("sites", admin_sites_url, {:id => 'show_site_list', :class => 'expandable'})
  chooser << %{<ul id="nav"><li>Current Site: #{current_site.name}}
  chooser << %{<ul class="expansion">#{options}</ul></li></ul>}
  chooser << %{</div>}
  chooser
end

end