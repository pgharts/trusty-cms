module SnippetTags
  include TrustyCms::Taggable
  
  class TagError < StandardError; end
  
  desc %{
    Renders the snippet specified in the @name@ attribute within the context of a page.

    *Usage:*

    <pre><code><r:snippet name="snippet_name" /></code></pre>

    When used as a double tag, the part in between both tags may be used within the
    snippet itself, being substituted in place of @<r:yield/>@.

    *Usage:*

    <pre><code><r:snippet name="snippet_name">Lorem ipsum dolor...</r:snippet></code></pre>
  }
  tag 'snippet' do |tag|
    required_attr(tag, 'name')
    name = tag['name']

    snippet = snippet_cache(name.strip)
    
    if snippet
      tag.locals.yield = tag.expand if tag.double?
      tag.globals.page.render_snippet(snippet)
    else
      raise TagError.new("snippet '#{name}' not found")
    end
  end

  def snippet_cache(name)
    @snippet_cache ||= {}

    snippet = @snippet_cache[name]
    unless snippet
      snippet = SnippetFinder.find_by_name(name)
      @snippet_cache[name] = snippet
    end
    snippet
  end
  private :snippet_cache

  desc %{
    Used within a snippet as a placeholder for substitution of child content, when
    the snippet is called as a double tag.

    *Usage (within a snippet):*
    
    <pre><code>
    <div id="outer">
      <p>before</p>
      <r:yield/>
      <p>after</p>
    </div>
    </code></pre>

    If the above snippet was named "yielding", you could call it from any Page,
    Layout or Snippet as follows:

    <pre><code><r:snippet name="yielding">Content within</r:snippet></code></pre>

    Which would output the following:

    <pre><code>
    <div id="outer">
      <p>before</p>
      Content within
      <p>after</p>
    </div>
    </code></pre>

    When called in the context of a Page or a Layout, @<r:yield/>@ outputs nothing.
  }
  tag 'yield' do |tag|
    tag.locals.yield
  end
end