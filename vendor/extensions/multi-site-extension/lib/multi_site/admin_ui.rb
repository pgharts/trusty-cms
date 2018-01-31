# This is included into AdminUI and defines editing regions for the site administration pages.
# Note that the AdminUI object is a singleton and it is not sufficient to add to its initialization routines: you also have to call load_default_site_regions on the admin singleton that has already been defined.

module MultiSite::AdminUI

 def self.included(base)
   base.class_eval {

      attr_accessor :site
      alias_method :sites, :site


        # The site-admin pages have these regions:
        
        # Edit view:
        # * main: edit_header, edit_form
        # * form: edit_name edit_domain edit_homepage
        # * form_bottom: edit_timestamp edit_buttons

        # Index view
        # * thead: title_header domain_header basedomain_header modify_header order_header
        # * tbody: title_cell domain_cell basedomain_cell modify_cell order_cell (repeating row)
        # * bottom: new_button

        def load_default_site_regions
          OpenStruct.new.tap do |site|
            site.edit = TrustyCms::AdminUI::RegionSet.new do |edit|
              edit.main.concat %w{edit_header edit_form}
              edit.form.concat %w{edit_name edit_domain edit_homepage}
              edit.form_bottom.concat %w{edit_timestamp edit_buttons}
            end
            site.index = TrustyCms::AdminUI::RegionSet.new do |index|
              index.thead.concat %w{title_header domain_header basedomain_header modify_header order_header}
              index.tbody.concat %w{title_cell domain_cell basedomain_cell modify_cell order_cell}
              index.bottom.concat %w{new_button}
            end
            site.remove = site.index
            site.new = site.edit
          end
        end
      
   }
  end
end

