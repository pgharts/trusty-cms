class HamlFilter < TextFilter
  def filter(text)
    Haml::Engine.new(text).render.gsub(/&lt;(\/)?r:(.+?)\s*(\/?\\?)&gt;/m,"<\\1r:\\2\\3>")
  end
end