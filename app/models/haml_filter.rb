class HamlFilter < TextFilter
  def filter(text)
    html = Haml::Template.new { text }.render
    html.gsub(/&lt;(\/)?r:(.+?)\s*(\/?\\?)&gt;/m, '<\1r:\2\3>')
  end
end