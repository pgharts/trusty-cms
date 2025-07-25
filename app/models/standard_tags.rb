require 'trusty_cms/taggable'
module StandardTags
  include TrustyCms::Taggable

  require 'will_paginate/view_helpers'
  include WillPaginate::ViewHelpers

  class TagError < StandardError; end

  desc %{
    Causes the tags referring to a page's attributes to refer to the current page.

    *Usage:*

    <pre><code><r:page>...</r:page></code></pre>
  }
  tag 'page' do |tag|
    tag.locals.page = tag.globals.page
    tag.expand
  end

  %i[breadcrumb slug title].each do |method|
    desc %{
      Renders the @#{method}@ attribute of the current page.
    }
    tag method.to_s do |tag|
      tag.locals.page.send(method)
    end
  end

  desc %{
    Renders the @path@ attribute of the current page.
  }
  tag 'path' do |tag|
    relative_url_for(tag.locals.page.path, tag.globals.page.request)
  end

  desc %{
    Gives access to a page's children.

    *Usage:*

    <pre><code><r:children>...</r:children></code></pre>
  }
  tag 'children' do |tag|
    tag.locals.children = tag.locals.page.children
    tag.expand
  end

  desc %{
    Renders the total number of children.
  }
  tag 'children:count' do |tag|
    options = children_find_options(tag)
    options.delete(:order) # Order is irrelevant
    tag.locals.children.count(options)
  end

  desc %{
    Returns the first child. Inside this tag all page attribute tags are mapped to
    the first child. Takes the same ordering options as @<r:children:each>@.

    *Usage:*

    <pre><code><r:children:first>...</r:children:first></code></pre>
  }
  tag 'children:first' do |tag|
    options = children_find_options(tag)
    children = tag.locals.children.where(options)
    if first = children.first
      tag.locals.page = first
      tag.expand
    end
  end

  desc %{
    Returns the last child. Inside this tag all page attribute tags are mapped to
    the last child. Takes the same ordering options as @<r:children:each>@.

    *Usage:*

    <pre><code><r:children:last>...</r:children:last></code></pre>
  }
  tag 'children:last' do |tag|
    options = children_find_options(tag)
    children = tag.locals.children.where(options)
    if last = children.last
      tag.locals.page = last
      tag.expand
    end
  end

  desc %{
    Cycles through each of the children. Inside this tag all page attribute tags
    are mapped to the current child page.

    Supply @paginated="true"@ to paginate the displayed list. will_paginate view helper
    options can also be specified, including @per_page@, @previous_label@, @next_label@,
    @class@, @separator@, @inner_window@ and @outer_window@.

    *Usage:*

    <pre><code><r:children:each [offset="number"] [limit="number"]
     [by="published_at|updated_at|created_at|slug|title|keywords|description"]
     [order="asc|desc"]
     [status="draft|reviewed|scheduled|published|hidden|all"]
     [paginated="true"]
     [per_page="number"]
     >
     ...
    </r:children:each>
    </code></pre>
  }
  tag 'children:each' do |tag|
    render_children_with_pagination(tag)
  end

  desc %{
    The pagination tag is not usually called directly. Supply paginated="true" when you display a list and it will
    be automatically display only the current page of results, with pagination controls at the bottom.

    *Usage:*

    <pre><code><r:children:each paginated="true" per_page="50" container="false" previous_label="foo" next_label="bar">
      <r:child>...</r:child>
    </r:children:each>
    </code></pre>
  }
  tag 'pagination' do |tag|
    if tag.locals.paginated_list
      will_paginate(tag.locals.paginated_list, will_paginate_options(tag))
    end
  end

  desc %{
    Page attribute tags inside of this tag refer to the current child. This is occasionally
    useful if you are inside of another tag (like &lt;r:find&gt;) and need to refer back to the
    current child.

    *Usage:*

    <pre><code><r:children:each>
      <r:child>...</r:child>
    </r:children:each>
    </code></pre>
  }
  tag 'children:each:child' do |tag|
    tag.locals.page = tag.locals.child
    tag.expand
  end

  desc %{
    Renders the tag contents only if the current page is the first child in the context of
    a children:each tag

    *Usage:*

    <pre><code><r:children:each>
      <r:if_first >
        ...
      </r:if_first>
    </r:children:each>
    </code></pre>

  }
  tag 'children:each:if_first' do |tag|
    tag.expand if tag.locals.first_child
  end

  desc %{
    Renders the tag contents unless the current page is the first child in the context of
    a children:each tag

    *Usage:*

    <pre><code><r:children:each>
      <r:unless_first >
        ...
      </r:unless_first>
    </r:children:each>
    </code></pre>

  }
  tag 'children:each:unless_first' do |tag|
    tag.expand unless tag.locals.first_child
  end

  desc %{
    Renders the tag contents only if the current page is the last child in the context of
    a children:each tag

    *Usage:*

    <pre><code><r:children:each>
      <r:if_last >
        ...
      </r:if_last>
    </r:children:each>
    </code></pre>

  }
  tag 'children:each:if_last' do |tag|
    tag.expand if tag.locals.last_child
  end

  desc %{
    Renders the tag contents unless the current page is the last child in the context of
    a children:each tag

    *Usage:*

    <pre><code><r:children:each>
      <r:unless_last >
        ...
      </r:unless_last>
    </r:children:each>
    </code></pre>

  }
  tag 'children:each:unless_last' do |tag|
    tag.expand unless tag.locals.last_child
  end

  desc %{
    Renders the tag contents only if the contents do not match the previous header. This
    is extremely useful for rendering date headers for a list of child pages.

    If you would like to use several header blocks you may use the @name@ attribute to
    name the header. When a header is named it will not restart until another header of
    the same name is different.

    Using the @restart@ attribute you can cause other named headers to restart when the
    present header changes. Simply specify the names of the other headers in a semicolon
    separated list.

    *Usage:*

    <pre><code><r:children:each>
      <r:header [name="header_name"] [restart="name1[;name2;...]"]>
        ...
      </r:header>
    </r:children:each>
    </code></pre>
  }
  tag 'children:each:header' do |tag|
    previous_headers = tag.locals.previous_headers
    name = tag.attr['name'] || :unnamed
    restart = (tag.attr['restart'] || '').split(';')
    header = tag.expand
    unless header == previous_headers[name]
      previous_headers[name] = header
      unless restart.empty?
        restart.each do |n|
          previous_headers[n] = nil
        end
      end
      header
    end
  end

  desc %{
    Page attribute tags inside this tag refer to the parent of the current page.

    *Usage:*

    <pre><code><r:parent>...</r:parent></code></pre>
  }
  tag 'parent' do |tag|
    parent = tag.locals.page.parent
    tag.locals.page = parent
    tag.expand if parent
  end

  desc %{
    Renders the contained elements only if the current contextual page has a parent, i.e.
    is not the root page.

    *Usage:*

    <pre><code><r:if_parent>...</r:if_parent></code></pre>
  }
  tag 'if_parent' do |tag|
    parent = tag.locals.page.parent
    tag.expand if parent
  end

  desc %{
    Renders the contained elements only if the current contextual page has no parent, i.e.
    is the root page.

    *Usage:*

    <pre><code><r:unless_parent>...</r:unless_parent></code></pre>
  }
  tag 'unless_parent' do |tag|
    parent = tag.locals.page.parent
    tag.expand unless parent
  end

  desc %{
    Renders the contained elements only if the current contextual page has one or
    more child pages.  The @status@ attribute limits the status of found child pages
    to the given status, the default is @"published"@. @status="all"@ includes all
    non-virtual pages regardless of status.

    *Usage:*

    <pre><code><r:if_children [status="published"]>...</r:if_children></code></pre>
  }
  tag 'if_children' do |tag|
    children = tag.locals.page.children.where(children_find_options(tag)[:conditions]).count
    tag.expand if children.positive?
  end

  desc %{
    Renders the contained elements only if the current contextual page has no children.
    The @status@ attribute limits the status of found child pages to the given status,
    the default is @"published"@. @status="all"@ includes all non-virtual pages
    regardless of status.

    *Usage:*

    <pre><code><r:unless_children [status="published"]>...</r:unless_children></code></pre>
  }
  tag 'unless_children' do |tag|
    children = tag.locals.page.children.where(children_find_options(tag)[:conditions]).count
    tag.expand unless children.positive?
  end

  desc %{
    Aggregates the children of multiple paths using the @paths@ attribute.
    Useful for combining many different sections/categories into a single
    feed or listing.

    *Usage*:

    <pre><code><r:aggregate paths="/section1; /section2; /section3"> ... </r:aggregate></code></pre>
  }
  tag 'aggregate' do |tag|
    required_attr(tag, 'paths', 'urls')
    paths = (tag.attr['paths'] || tag.attr['urls']).split(';').map(&:strip).reject(&:blank?).map { |u| clean_path u }
    parent_ids = paths.map { |u| Page.find_by_path(u) }.map(&:id)
    tag.locals.parent_ids = parent_ids
    tag.expand
  end

  desc %{
    Sets the scope to the individual aggregated page allowing you to
    iterate through each of the listed paths.

    *Usage*:

    <pre><code><r:aggregate:each paths="/section1; /section2; /section3"> ... </r:aggregate:each></code></pre>
  }
  tag 'aggregate:each' do |tag|
    aggregates = []
    tag.locals.aggregated_pages = tag.locals.parent_ids.map { |p| Page.find(p) }
    tag.locals.aggregated_pages.each do |aggregate_page|
      tag.locals.page = aggregate_page
      aggregates << tag.expand
    end
    aggregates.flatten.join
  end

  tag 'aggregate:each:children' do |tag|
    tag.locals.children = tag.locals.page.children
    tag.expand
  end

  tag 'aggregate:each:children:each' do |tag|
    options = children_find_options(tag)
    result = []
    children = tag.locals.children
    tag.locals.previous_headers = {}
    children.where(options).each do |item|
      tag.locals.child = item
      tag.locals.page = item
      result << tag.expand
    end
    result.flatten.join
  end

  tag 'aggregate:children' do |tag|
    tag.expand
  end

  desc %{
    Renders the total count of children of the aggregated pages.  Accepts the
    same options as @<r:children:each />@.

    *Usage*:

    <pre><code><r:aggregate paths="/section1; /section2; /section3">
      <r:children:count />
    </r:aggregate></code></pre>
  }
  tag 'aggregate:children:count' do |tag|
    options = aggregate_children(tag)
    if ActiveRecord::Base.connection.adapter_name.downcase == 'postgresql'
      options[:group] = Page.columns.map { |c| c.name }.join(', ')
      Page.where(options).size
    else
      Page.where(options).count
    end
  end
  desc %{
    Renders the contained block for each child of the aggregated pages.  Accepts the
    same options as the plain @<r:children:each />@.

    *Usage*:

    <pre><code><r:aggregate paths="/section1; /section2; /section3">
      <r:children:each>
        ...
      </r:children:each>
    </r:aggregate></code></pre>
  }
  tag 'aggregate:children:each' do |tag|
    render_children_with_pagination(tag, aggregate: true)
  end

  desc %{
    Renders the first child of the aggregated pages.  Accepts the
    same options as @<r:children:each />@.

    *Usage*:

    <pre><code><r:aggregate paths="/section1; /section2; /section3">
      <r:children:first>
        ...
      </r:children:first>
    </r:aggregate></code></pre>
  }
  tag 'aggregate:children:first' do |tag|
    options = aggregate_children(tag)
    children = Page.where(options)

    if first = children.first
      tag.locals.page = first
      tag.expand
    end
  end

  desc %{
    Renders the last child of the aggregated pages.  Accepts the
    same options as @<r:children:each />@.

    *Usage*:

    <pre><code><r:aggregate paths="/section1; /section2; /section3">
      <r:children:last>
        ...
      </r:children:last>
    </r:aggregate></code></pre>
  }
  tag 'aggregate:children:last' do |tag|
    options = aggregate_children(tag)
    children = Page.where(options)

    if last = children.last
      tag.locals.page = last
      tag.expand
    end
  end

  desc %{
    Renders the main content of a page. Use the @part@ attribute to select a specific
    page part. By default the @part@ attribute is set to body. Use the @inherit@
    attribute to specify that if a page does not have a content part by that name that
    the tag should render the parent's content part. By default @inherit@ is set to
    @false@. Use the @contextual@ attribute to force a part inherited from a parent
    part to be evaluated in the context of the child page. By default 'contextual'
    is set to true.

    *Usage:*

    <pre><code><r:content [part="part_name"] [inherit="true|false"] [contextual="true|false"] /></code></pre>
  }
  tag 'content' do |tag|
    page = tag.locals.page
    part_name = tag_part_name(tag)
    # Prevent simple and deep recursive rendering of the same page part
    rendering_parts = (tag.locals.rendering_parts ||= Hash.new { |h, k| h[k] = [] })
    if rendering_parts[page.id].include?(part_name)
      raise TagError.new(%{Recursion error: already rendering the `#{part_name}' part.})
    else
      rendering_parts[page.id] << part_name
    end

    inherit = boolean_attr_or_error(tag, 'inherit', false)
    part_page = page
    if inherit
      while part_page.part(part_name).nil? && (not part_page.parent.nil?)
        part_page = part_page.parent
      end
    end
    contextual = boolean_attr_or_error(tag, 'contextual', true)
    part = part_page.part(part_name)
    tag.locals.page = part_page unless contextual
    result = tag.globals.page.render_snippet(part) unless part.nil?
    rendering_parts[page.id].delete(part_name)
    result
  end

  desc %{
    Renders the containing elements if all of the listed parts exist on a page.
    By default the @part@ attribute is set to @body@, but you may list more than one
    part by separating them with a comma. Setting the optional @inherit@ to true will
    search ancestors independently for each part. By default @inherit@ is set to @false@.

    When listing more than one part, you may optionally set the @find@ attribute to @any@
    so that it will render the containing elements if any of the listed parts are found.
    By default the @find@ attribute is set to @all@.

    *Usage:*

    <pre><code><r:if_content [part="part_name, other_part"] [inherit="true"] [find="any"]>...</r:if_content></code></pre>
  }
  tag 'if_content' do |tag|
    part_name = tag_part_name(tag)
    parts_arr = part_name.split(',')
    inherit = boolean_attr_or_error(tag, 'inherit', 'false')
    find = attr_or_error(tag, attribute_name: 'find', default: 'all', values: 'any, all')
    expandable = true
    one_found = false
    parts_arr.each do |name|
      part_page = tag.locals.page
      name.strip!
      if inherit
        while part_page.part(name).nil? && (not part_page.parent.nil?)
          part_page = part_page.parent
        end
      end
      expandable = false if part_page.part(name).nil?
      one_found ||= true if !part_page.part(name).nil?
    end
    expandable = true if (find == 'any') && one_found
    tag.expand if expandable
  end

  desc %{
    The opposite of the @if_content@ tag. It renders the contained elements if all of the
    specified parts do not exist. Setting the optional @inherit@ to true will search
    ancestors independently for each part. By default @inherit@ is set to @false@.

    When listing more than one part, you may optionally set the @find@ attribute to @any@
    so that it will not render the containing elements if any of the listed parts are found.
    By default the @find@ attribute is set to @all@.

    *Usage:*

    <pre><code><r:unless_content [part="part_name, other_part"] [inherit="false"] [find="any"]>...</r:unless_content></code></pre>
  }
  tag 'unless_content' do |tag|
    part_name = tag_part_name(tag)
    parts_arr = part_name.split(',')
    inherit = boolean_attr_or_error(tag, 'inherit', false)
    find = attr_or_error(tag, attribute_name: 'find', default: 'all', values: 'any, all')
    expandable = true
    all_found = true
    parts_arr.each do |name|
      part_page = tag.locals.page
      name.strip!
      if inherit
        while part_page.part(name).nil? && (not part_page.parent.nil?)
          part_page = part_page.parent
        end
      end
      expandable = false if !part_page.part(name).nil?
      all_found = false if part_page.part(name).nil?
    end
    if (all_found == false) && (find == 'all')
      expandable = true
    end
    tag.expand if expandable
  end

  desc %{
    Renders the containing elements only if the page's path matches the regular expression
    given in the @matches@ attribute. If the @ignore_case@ attribute is set to false, the
    match is case sensitive. By default, @ignore_case@ is set to true.

    *Usage:*

    <pre><code><r:if_path matches="regexp" [ignore_case="true|false"]>...</r:if_path></code></pre>
  }
  tag 'if_path' do |tag|
    required_attr(tag, 'matches')
    regexp = build_regexp_for(tag, 'matches')
    unless tag.locals.page.path.match(regexp).nil?
      tag.expand
    end
  end

  desc %{
    The opposite of the @if_path@ tag.

    *Usage:*

    <pre><code><r:unless_path matches="regexp" [ignore_case="true|false"]>...</r:unless_path></code></pre>
  }
  tag 'unless_path' do |tag|
    required_attr(tag, 'matches')
    regexp = build_regexp_for(tag, 'matches')
    if tag.locals.page.path.match(regexp).nil?
      tag.expand
    end
  end

  desc %{
    Renders the contained elements if the current contextual page is either the actual page or one of its parents.

    This is typically used inside another tag (like &lt;r:children:each&gt;) to add conditional mark-up if the child element is or descends from the current page.

    *Usage:*

    <pre><code>...</code></pre>
  }

  tag 'unless_ancestor_or_self' do |tag|
    tag.expand unless (tag.globals.page.ancestors + [tag.globals.page]).include?(tag.locals.page)
  end

  desc %{
    Renders the contained elements if the current contextual page is also the actual page.

    This is typically used inside another tag (like &lt;r:children:each&gt;) to add conditional mark-up if the child element is the current page.

    *Usage:*

    <pre><code><r:if_self>...</r:if_self></code></pre>
  }
  tag 'if_self' do |tag|
    tag.expand if tag.locals.page == tag.globals.page
  end

  desc %{
    Renders the contained elements unless the current contextual page is also the actual page.

    This is typically used inside another tag (like &lt;r:children:each&gt;) to add conditional mark-up unless the child element is the current page.

    *Usage:*

    <pre><code><r:unless_self>...</r:unless_self></code></pre>
  }
  tag 'unless_self' do |tag|
    tag.expand unless tag.locals.page == tag.globals.page
  end

  desc %{
    Renders the name of the author of the current page.
  }
  tag 'author' do |tag|
    page = tag.locals.page
    if author = page.created_by
      author.name
    end
  end

  desc %{
    Renders the date based on the current page (by default when it was published or created).
    The format attribute uses the same formating codes used by the Ruby @strftime@ function.
    By default it's set to @%A, %B %d, %Y@. You may also use the string @rfc1123@ as a shortcut
    for @%a, %d %b %Y %H:%M:%S GMT@ (non-localized). The @for@ attribute selects which date to
    render. Valid options are @published_at@, @created_at@, @updated_at@, and @now@. @now@ will
    render the current date/time, regardless of the page.

    *Usage:*

    <pre><code><r:date [format="%A, %B %d, %Y"] [for="published_at"]/></code></pre>
  }
  tag 'date' do |tag|
    page = tag.locals.page
    format = (tag.attr['format'] || '%A, %B %d, %Y')
    time_attr = tag.attr['for']
    date = if time_attr
             if time_attr == 'now'
               Time.zone.now
             elsif Page.date_column_names.include?(time_attr)
               page[time_attr]
             else
               raise TagError, "Invalid value for 'for' attribute."
             end
           else
             page.published_at || page.created_at
    end
    case format
    when 'rfc1123'
      CGI.rfc1123_date(date.to_time)
    else
      @i18n_date_format_keys ||= begin
                                   begin
                                    I18n.config.backend.send(:translations)[I18n.locale][:date][:formats].keys
                                   rescue StandardError
                                     []
                                  end
                                 end
      format = @i18n_date_format_keys.include?(format.to_sym) ? format.to_sym : format
      I18n.l date, format: format
    end
  end

  desc %{
    Inside this tag all page related tags refer to the page found at the @path@ attribute.
    @path@s may be relative or absolute paths.

    *Usage:*

    <pre><code><r:find path="value_to_find">...</r:find></code></pre>
  }
  tag 'find' do |tag|
    required_attr(tag, 'path', 'url')
    path = tag.attr['path'] || tag.attr['url']
    found = Page.find_by_path(absolute_path_for(tag.locals.page.path, path))
    if page_found?(found)
      tag.locals.page = found
      tag.expand
    end
  end

  desc %{
    Randomly renders one of the options specified by the @option@ tags.

    *Usage:*

    <pre><code><r:random>
      <r:option>...</r:option>
      <r:option>...</r:option>
      ...
    <r:random>
    </code></pre>
  }
  tag 'random' do |tag|
    tag.locals.random = []
    tag.expand
    options = tag.locals.random
    option = options[rand(options.size)]
    option
  end
  tag 'random:option' do |tag|
    items = tag.locals.random
    items << tag.expand
  end

  desc %{
    Nothing inside a set of hide tags is rendered.

    *Usage:*

    <pre><code><r:hide>...</r:hide></code></pre>
  }
  tag 'hide' do |tag|
  end

  desc %{
    Escapes angle brackets, etc. for rendering in an HTML document.

    *Usage:*

    <pre><code><r:escape_html>...</r:escape_html></code></pre>
  }
  tag 'escape_html' do |tag|
    CGI.escapeHTML(tag.expand)
  end

  desc %{
    Renders a list of links specified in the @paths@ attribute according to three
    states:

    * @normal@ specifies the normal state for the link
    * @here@ specifies the state of the link when the path matches the current
       page's PATH
    * @selected@ specifies the state of the link when the current page matches
       is a child of the specified path
    # @if_last@ renders its contents within a @normal@, @here@ or
      @selected@ tag if the item is the last in the navigation elements
    # @if_first@ renders its contents within a @normal@, @here@ or
      @selected@ tag if the item is the first in the navigation elements

    The @between@ tag specifies what should be inserted in between each of the links.

    *Usage:*

    <pre><code><r:navigation paths="[Title: path | Title: path | ...]">
      <r:normal><a href="<r:path />"><r:title /></a></r:normal>
      <r:here><strong><r:title /></strong></r:here>
      <r:selected><strong><a href="<r:path />"><r:title /></a></strong></r:selected>
      <r:between> | </r:between>
    </r:navigation>
    </code></pre>
  }
  tag 'navigation' do |tag|
    hash = tag.locals.navigation = {}
    tag.expand
    raise TagError.new("`navigation' tag must include a `normal' tag") unless hash.has_key? :normal

    result = []
    pairs = (tag.attr['paths'] || tag.attr['urls']).to_s.split('|').map do |pair|
      parts = pair.split(':')
      value = parts.pop
      key = parts.join(':')
      [key.strip, value.strip]
    end
    pairs.each_with_index do |(title, path), i|
      compare_path = remove_trailing_slash(path)
      page_path = remove_trailing_slash(path)
      hash[:title] = title
      hash[:path] = path
      tag.locals.first_child = i.zero?
      tag.locals.last_child = i == pairs.length - 1
      result << case page_path
                when compare_path
                  (hash[:here] || hash[:selected] || hash[:normal]).call
                when Regexp.compile('^' + Regexp.quote(path))
                  (hash[:selected] || hash[:normal]).call
                else
                  hash[:normal].call
                end
    end
    between = hash.has_key?(:between) ? hash[:between].call : ' '
    result.reject { |i| i.blank? }.join(between)
  end
  %i[normal here selected between].each do |symbol|
    tag "navigation:#{symbol}" do |tag|
      hash = tag.locals.navigation
      hash[symbol] = tag.block
    end
  end
  %i[title path].each do |symbol|
    tag "navigation:#{symbol}" do |tag|
      hash = tag.locals.navigation
      hash[symbol]
    end
  end
  tag 'navigation:path' do |tag|
    hash = tag.locals.navigation
    hash[:path]
  end

  desc %{
    Renders the containing elements if the element is the first
    in the navigation list

    *Usage:*

    <pre><code><r:normal><r:if_first>...</r:if_first></r:normal></code></pre>
  }
  tag 'navigation:if_first' do |tag|
    tag.expand if tag.locals.first_child
  end

  desc %{
    Renders the containing elements unless the element is the first
    in the navigation list

    *Usage:*

    <pre><code><r:normal><r:unless_first>...</r:unless_first></r:normal></code></pre>
  }
  tag 'navigation:unless_first' do |tag|
    tag.expand unless tag.locals.first_child
  end

  desc %{
    Renders the containing elements unless the element is the last
    in the navigation list

    *Usage:*

    <pre><code><r:normal><r:unless_last>...</r:unless_last></r:normal></code></pre>
  }
  tag 'navigation:unless_last' do |tag|
    tag.expand unless tag.locals.last_child
  end

  desc %{
    Renders the containing elements if the element is the last
    in the navigation list

    *Usage:*

    <pre><code><r:normal><r:if_last>...</r:if_last></r:normal></code></pre>
  }
  tag 'navigation:if_last' do |tag|
    tag.expand if tag.locals.last_child
  end

  tag 'site' do |tag|
    tag.expand
  end
  desc %{
    Returns TrustyCms::Config['site.title'] as configured under the Settings tab.
  }
  tag 'site:title' do |_tag|
    TrustyCms::Config['site.title']
  end
  desc %{
    Returns TrustyCms::Config['site.host'] as configured under the Settings tab.
  }
  tag 'site:host' do |_tag|
    TrustyCms::Config['site.host']
  end

  tag 'meta' do |tag|
    if tag.double?
      tag.expand
    else
      tag.render('description', tag.attr) + tag.render('keywords', tag.attr)
    end
  end

  tag 'meta:description' do |tag|
    show_tag = tag.attr['tag'] != 'false' || false
    description = CGI.escapeHTML(tag.locals.page.field(:description).try(:content)) if tag.locals.page.field(:description)
    if show_tag
      "<meta name=\"description\" content=\"#{description}\" />"
    else
      description
    end
  end

  tag 'meta:keywords' do |tag|
    show_tag = tag.attr['tag'] != 'false' || false
    keywords = CGI.escapeHTML(tag.locals.page.field(:keywords).try(:content)) if tag.locals.page.field(:keywords)
    if show_tag
      "<meta name=\"keywords\" content=\"#{keywords}\" />"
    else
      keywords
    end
  end

  private

  def render_children_with_pagination(tag, opts = {})
    if opts[:aggregate]
      findable = Page
      options = aggregate_children(tag)
    else
      findable = tag.locals.children
      options = children_find_options(tag)
    end
    paging = pagination_find_options(tag)
    result = []
    tag.locals.previous_headers = {}
    displayed_children = paging ? findable.paginate(options.merge(paging)) : findable.all.where(options[:conditions]).order(options[:order])
    displayed_children.each_with_index do |item, i|
      tag.locals.child = item
      tag.locals.page = item
      tag.locals.first_child = i == 0
      tag.locals.last_child = i == displayed_children.length - 1
      result << tag.expand
    end
    if paging && displayed_children.total_pages > 1
      tag.locals.paginated_list = displayed_children
      result << tag.render('pagination', tag.attr.dup)
    end
    result.flatten.join
  end

  def children_find_options(tag)
    attr = tag.attr.symbolize_keys

    options = {}

    %i[limit offset].each do |symbol|
      if number = attr[symbol]
        if number =~ /^\d+$/
          options[symbol] = number.to_i
        else
          raise TagError.new("`#{symbol}' attribute must be a positive number")
        end
      end
    end

    by = (attr[:by] || 'published_at').strip
    order = (attr[:order] || 'asc').strip
    order_string = ''
    if attributes.keys.include?(by)
      order_string << by
    else
      raise TagError.new("`by' attribute of `each' tag must be set to a valid field name")
    end
    if order =~ /^(asc|desc)$/i
      order_string << " #{$1.upcase}"
    else
      raise TagError.new(%{`order' attribute of `each' tag must be set to either "asc" or "desc"})
    end
    options[:order] = order_string

    status = attr[:status]
    if status == 'all'
      options[:conditions] = ['virtual = ?', false]
    else
      stat = Status[status]
      if stat.nil?
        raise TagError.new(%{`status' attribute of `each' tag must be set to a valid status})
      else
        options[:conditions] = ['(virtual = ?) and (status_id = ?)', false, stat.id]
      end
    end
    options
  end

  def aggregate_children(tag)
    options = children_find_options(tag)
    parent_ids = tag.locals.parent_ids

    conditions = options[:conditions]
    conditions.first << ' AND parent_id IN (?)'
    conditions << parent_ids
    options
  end

  def pagination_find_options(tag)
    attr = tag.attr.symbolize_keys
    if attr[:paginated] == 'true'
      pagination_parameters.merge(attr.slice(:per_page))
    else
      false
    end
  end

  def will_paginate_options(tag)
    attr = tag.attr.symbolize_keys
    if attr[:paginated] == 'true'
      attr.slice(:class, :previous_label, :next_label, :inner_window, :outer_window, :separator, :per_page).merge({ renderer: TrustyCms::Pagination::LinkRenderer.new(tag.globals.page.path) })
    else
      {}
    end
  end

  def remove_trailing_slash(string)
    string =~ %r{^(.*?)/$} ? $1 : string
  end

  def tag_part_name(tag)
    tag.attr['part'] || 'body'
  end

  def build_regexp_for(tag, attribute_name)
    ignore_case = tag.attr.has_key?('ignore_case') && tag.attr['ignore_case'] == 'false' ? nil : true
    begin
      regexp = Regexp.new(tag.attr['matches'], ignore_case)
    rescue RegexpError => e
      raise TagError.new("Malformed regular expression in `#{attribute_name}' argument of `#{tag.name}' tag: #{e.message}")
    end
    regexp
  end

  def relative_url_for(url, _request)
    File.join(ActionController::Base.relative_url_root || '', url)
  end

  def absolute_path_for(base_path, new_path)
    if new_path.first == '/'
      new_path
    else
      File.expand_path(File.join(base_path, new_path))
    end
  end

  def page_found?(page)
    page && !(FileNotFoundPage === page)
  end

  def boolean_attr_or_error(tag, attribute_name, default)
    attribute = attr_or_error(tag, attribute_name: attribute_name, default: default.to_s, values: 'true, false')
    attribute.to_s.downcase == 'true'
  end

  def attr_or_error(tag, options = {})
    attribute_name = options[:attribute_name].to_s
    default = options[:default]
    values = options[:values].split(',').map!(&:strip)

    attribute = (tag.attr[attribute_name] || default).to_s
    raise TagError.new(%{`#{attribute_name}' attribute of `#{tag.name}' tag must be one of: #{values.join(', ')}}) unless values.include?(attribute)

    attribute
  end

  def required_attr(tag, *attribute_names)
    attr_collection = attribute_names.map { |a| "`#{a}'" }.join(' or ')
    raise TagError.new("`#{tag.name}' tag must contain a #{attr_collection} attribute.") if (tag.attr.keys & attribute_names).blank?
  end
end
