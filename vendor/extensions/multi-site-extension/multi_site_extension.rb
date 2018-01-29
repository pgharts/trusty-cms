require_dependency 'application_controller'

class MultiSiteExtension < TrustyCms::Extension
  version "3.0.2"
  description %{ Enables virtual sites to be created with associated domain names.
                 Also scopes the sitemap view to any given page (or the root of an
                 individual site) and allows model classes to be scoped by site. }
  url "http://trustarts.org/"


  def activate

    # Model extensions
    ActiveRecord::Base.send :include, MultiSite::ScopedModel
    Page.send :include, MultiSite::PageExtensions

    # Controller extensions
    ApplicationController.send :include, MultiSite::ApplicationControllerExtensions
    Admin::ResourceController.send :include, MultiSite::ApplicationControllerExtensions
    ApplicationController.send :include, MultiSite::ApplicationControllerFilterExtensions

    #ActionController::Base.send :include, MultiSite::ApplicationControllerExtensions
    SiteController.send :include, MultiSite::SiteControllerExtensions
    Admin::ResourceController.send :include, MultiSite::ResourceControllerExtensions
    Admin::PagesController.send :include, MultiSite::PagesControllerExtensions
    Admin::ResourceController.send :helper, MultiSite::SiteChooserHelper
    Admin::PagesController.send :helper, MultiSite::SiteChooserHelper
    admin.layouts.index.add(:before_nav, "admin/layouts/site_chooser")
    admin.pages.index.add(:before_nav, "admin/layouts/site_chooser")
    admin.snippets.index.add(:before_nav, "admin/layouts/site_chooser")
    Layout.send :is_site_scoped
    Snippet.send :is_site_scoped
    User.send :is_site_scoped, :shareable => true
    ApplicationHelper.send :include, ScopedHelper

    unless admin.users.edit.form && admin.users.edit.form.include?('choose_site')
      admin.users.edit.add :form, "choose_site", :after => "edit_roles"
      admin.layouts.edit.add :form, "choose_site", :before => "edit_timestamp"
      admin.snippets.edit.add :form, "choose_site", :before => "edit_filter" unless admin.snippets.edit.form.include?("choose_site")
    end


    unless defined? admin.site
      TrustyCms::AdminUI.send :include, MultiSite::AdminUI
      admin.site = TrustyCms::AdminUI.load_default_site_regions
    end

    if respond_to?(:tab)
      tab("Settings") do
        add_item "Sites", "/admin/sites", :after => "Extensions", :visibility => [:admin]
      end
    else
      admin.tabs.add "Sites", "/admin/sites", :visibility => [:admin]
    end
  end

  def deactivate
  end
end

class ActiveRecord::SiteNotFound < Exception; end
