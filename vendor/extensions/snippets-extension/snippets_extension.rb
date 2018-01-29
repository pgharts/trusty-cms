class SnippetsExtension < TrustyCms::Extension

  def activate
    if defined?(Radiant::Exporter)
      TrustyCms::Exporter.exportable_models << Snippet
      TrustyCms::Exporter.template_models << Snippet
    end

    Page.class_eval do
      include SnippetTags
    end

    TrustyCms::AdminUI.class_eval do
      attr_accessor :snippet

      alias_method :snippets, :snippet

      def load_default_snippet_regions
        OpenStruct.new.tap do |snippet|
          snippet.edit = TrustyCms::AdminUI::RegionSet.new do |edit|
            edit.main.concat %w{edit_header edit_form}
            edit.form.concat %w{edit_title edit_content edit_filter}
            edit.form_bottom.concat %w{edit_buttons edit_timestamp}
          end
          snippet.index = TrustyCms::AdminUI::RegionSet.new do |index|
            index.top.concat %w{}
            index.thead.concat %w{title_header actions_header}
            index.tbody.concat %w{title_cell actions_cell}
            index.bottom.concat %w{new_button}
          end
          snippet.new = snippet.edit
          snippet.remove = snippet.edit
        end
      end
    end

    admin.snippet       ||= TrustyCms::AdminUI.load_default_snippet_regions

    UserActionObserver.instance.send :add_observer!, ::Snippet

    tab 'Design' do
      add_item "Snippets", "/admin/snippets"
    end

  end
end
