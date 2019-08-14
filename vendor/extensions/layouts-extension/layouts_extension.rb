class LayoutsExtension < TrustyCms::Extension
  description "A set of useful extensions to standard Layouts."

  def activate
    # Shared Layouts
    RailsPage
    ApplicationController.send :include, ShareLayouts::Controllers::ActionController
    ActionView::Base.send :include, ShareLayouts::Helpers::ActionView

    # Nested Layouts
    Page.send   :include, NestedLayouts::Tags::Core

    # HAML Layouts
    Layout.send  :include, HamlLayouts::Models::Layout
    Page.send    :include, HamlLayouts::Models::Page
    HamlFilter
  end

end
