module AssetTags
  include TrustyCms::Taggable
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::AssetTagHelper
  
  class TagError < StandardError; end
  
  %w{top_padding width height caption asset_file_name asset_content_type asset_file_size id filename image flash thumbnail url link extension if_content_type page:title page:url}.each do |name|
    deprecated_tag "assets:#{name}", :substitute => "asset:#{name}", :deadline => '2.0'
  end
  
  desc %{
    The namespace for referencing images and assets.
    
    *Usage:* 
    <pre><code><r:asset [name="asset name"]>...</r:asset></code></pre>
  }    
  tag 'asset' do |tag|
    tag.locals.asset = find_asset(tag, tag.attr) unless tag.attr.empty?
      tag.expand
  end

  desc %{
    Cycles through all assets attached to the current page.  
    This tag does not require the name atttribute, nor do any of its children.
    Use the @limit@ and @offset@ attribute to render a specific number of assets.
    Use @by@ and @order@ attributes to control the order of assets.
    Use @extensions@ attribute to specify which assets to be rendered.
    
    *Usage:* 
    <pre><code><r:assets:each [limit=0] [offset=0] [order="asc|desc"] [by="position|title|..."] [extensions="png|pdf|doc"]>...</r:assets:each></code></pre>
  }    
  tag 'assets' do |tag|
    tag.expand
  end
  tag 'assets:each' do |tag|
    options = tag.attr.dup
    tag.locals.assets = tag.locals.page.assets.scoped(assets_find_options(tag))
    tag.render('asset_list', tag.attr.dup, &tag.block)
  end

  # General purpose paginated asset lister. Very useful dryness.
  # Tag.locals.assets must be defined but can be empty.

  tag 'asset_list' do |tag|
    raise TagError, "r:asset_list: no assets to list" unless tag.locals.assets
    options = tag.attr.symbolize_keys
    result = ""
    paging = pagination_find_options(tag)
    assets = paging ? tag.locals.assets.paginate(paging) : tag.locals.assets.all
    assets.each do |asset|
      tag.locals.asset = asset
      result << tag.expand
    end
    if paging && assets.total_pages > 1
      tag.locals.paginated_list = assets
      result << tag.render('pagination', tag.attr.dup)
    end
    result
  end
  
  desc %{
    References the first asset attached to the current page.  
    
    *Usage:* 
    <pre><code><r:assets:first>...</r:assets:first></code></pre>
  }
  tag 'assets:first' do |tag|
    if tag.locals.asset = tag.locals.page.assets.first
      tag.expand
    end
  end

  desc %{
    Renders the contained elements only if the current contextual page has one or
    more assets. The @min_count@ attribute specifies the minimum number of required
    assets. You can also filter by extensions with the @extensions@ attribute.
  
    *Usage:*
    <pre><code><r:if_assets [min_count="n"]>...</r:if_assets></code></pre>
  }
  tag 'if_assets' do |tag|
    count = tag.attr['min_count'] && tag.attr['min_count'].to_i || 1
    assets = tag.locals.page.assets.count(:conditions => assets_find_options(tag)[:conditions])
    tag.expand if assets >= count
  end
  
  desc %{
    The opposite of @<r:if_assets/>@.
  }
  tag 'unless_assets' do |tag|
    count = tag.attr['min_count'] && tag.attr['min_count'].to_i || 1
    assets = tag.locals.page.assets.count(:conditions => assets_find_options(tag)[:conditions])
    tag.expand unless assets >= count
  end
  
  # Resets the page Url and title within the asset tag
  [:title, :url].each do |method|
    tag "asset:page:#{method.to_s}" do |tag|
      tag.locals.page.send(method)
    end
  end







  desc %{
    Renders the value for a top padding for a thumbnail. Put the thumbnail in a
    container with specified height and using this tag you can vertically
    align the image within its container.
  
    *Usage*:
    <pre><code><r:asset:top_padding container = "140" [size="icon"]/></code></pre>
  
    *Working Example*:
    <pre><code>
      <ul>
        <r:asset:each>
          <li style="height:140px">
            <img style="padding-top:<r:top_padding size='category' container='140' />px" 
                 src="<r:url />" alt="<r:title />" />
          </li>
        </r:asset:each>
      </ul>
    </code></pre>
  }
  tag 'asset:top_padding' do |tag|
    asset, options = asset_and_options(tag)
    raise TagError, "'container' attribute required" unless options['container']
    size = options['size'] ? options.delete('size') : 'icon'
    raise TagError, "asset #{tag.locals.asset.title} has no '#{size}' thumbnail" unless tag.locals.asset.has_style?(size)
    container = options.delete('container')
    ((container.to_i - asset.height(size).to_i)/2).to_s
  end
    
  ['height','width'].each do |dimension|
    desc %{
      Renders the #{dimension} of the asset.
    }
    tag "asset:#{dimension}" do |tag|
      asset, options = asset_and_options(tag)
      unless asset.dimensions_known?
        raise TagError, "Can't determine #{dimension} for this Asset. It may not be a supported type."
      end
      size = options['size'] ? options.delete('size') : 'original'
      asset.send(dimension, size)
    end
  end

  desc %{
    Returns a string representing the orientation of the asset, which must be imageable. 
    (ie, it is an image or it has been processed to produce an image). 
    Can be 'horizontal', 'vertical' or 'square'.
  }
  tag 'asset:orientation' do |tag|
    asset, options = asset_and_options(tag)
    size = options['size'] ? options.delete('size') : 'original'
    raise TagError, "asset #{tag.locals.asset.title} has no '#{size}' thumbnail" unless tag.locals.asset.has_style?(size)
    asset.orientation(size)
  end

  desc %{
    Returns the aspect ratio of the asset, which must be an image.
  }
  tag 'asset:aspect' do |tag|
    asset, options = asset_and_options(tag)
    size = options['size'] ? options.delete('size') : 'original'
    raise TagError, "asset #{tag.locals.asset.title} has no '#{size}' thumbnail" unless tag.locals.asset.has_style?(size)
    asset.aspect(size)
  end

  desc %{
    Renders the containing elements only if the asset's content type matches
    the regular expression given in the @matches@ attribute. If the
    @ignore_case@ attribute is set to false, the match is case sensitive. By
    default, @ignore_case@ is set to true.
      
    The @name@ or @id@ attribute is required on the parent tag unless this tag is used in @asset:each@.

    *Usage:* 
    <pre><code><r:asset:each><r:if_content_type matches="regexp" [ignore_case=true|false"]>...</r:if_content_type></r:asset:each></code></pre>
  }
  tag 'asset:if_content_type' do |tag|
    options = tag.attr.dup
    # XXX build_regexp_for comes from StandardTags
    regexp = build_regexp_for(tag,options)
    asset_content_type = tag.locals.asset.asset_content_type
    tag.expand unless asset_content_type.match(regexp).nil?
  end
  
  #TODO: could use better docs for Asset#other? case explaining what types it covers
  
  [:title, :caption, :asset_file_name, :extension, :asset_content_type, :asset_file_size, :id].each do |method|
    desc %{
      Renders the @#{method.to_s}@ attribute of the asset
    }
    tag "asset:#{method.to_s}" do |tag|
      asset, options = asset_and_options(tag)
      asset.send(method) rescue nil
    end
  end
  
  tag 'asset:name' do |tag|
    tag.render('asset:title', tag.attr.dup)
  end  
  
  tag 'asset:filename' do |tag|
    asset, options = asset_and_options(tag)
    asset.asset_file_name rescue nil
  end
  
  desc %{
    Renders an image tag for the asset.
    
    Using the optional @size@ attribute, different sizes can be display.
    "thumbnail" and "icon" sizes are built in, but custom ones can be set
    by changing `assets.thumbnails.[type]` in the TrustyCms::Config settings.
    
    *Usage:* 
    <pre><code><r:asset:image [name="asset name" or id="asset id"] [size="icon|thumbnail|whatever"]></code></pre>
  }    
  tag 'asset:image' do |tag|
    tag.locals.asset, options = asset_and_options(tag)
    size = options.delete('size') || 'original'
    raise TagError, "asset #{tag.locals.asset.title} has no '#{size}' thumbnail" unless tag.locals.asset.has_style?(size)
    options['alt'] ||= tag.locals.asset.title
    url = tag.locals.asset.thumbnail(size)
    ActionController::Base.helpers.image_tag(url, options)
  end
  
  desc %{
    Embeds a flash-movie in a cross-browser-compatible fashion using only HTML
    If no width and height attributes are given it will use the intrinsic
    dimensions of the swf file
    
    *Usage:*
    <pre><code><r:asset:flash [name="asset name" or id="asset id"] [width="100"] [height="100"]>Fallback content</flash></code></pre>
    
    *Example with text fallback:*
    <pre><code><r:asset:flash name="flash_movie">
        Sorry, you need to have flash installed, <a href="http://adobe.com/flash">get it here</a>
    </flash></code></pre>
    
    *Example with image fallback and explicit dimensions:*
    <pre><code><r:asset:flash name="flash_movie" width="300" height="200">
        <r:asset:image name="flash_screenshot" />
      </flash></code></pre>
  }
  tag 'asset:flash' do |tag|
    asset, options = asset_and_options(tag)
    if tag.locals.asset.flash?
      url = asset.thumbnail('original')
      dimensions = [(tag.attr['width'] || asset.width),(tag.attr['height'] || asset.height)]
      swf_embed_markup url, dimensions, tag.expand
    end
  end
    
  desc %{
    Renders the url for the asset. If the asset is an image, the <code>size</code> attribute can be used to 
    generate the url for that size. 
    
    *Usage:* 
    <pre><code><r:url [name="asset name" or id="asset id"] [size="icon|thumbnail"]></code></pre>
  }    
  tag 'asset:url' do |tag|
    asset, options = asset_and_options(tag)
    size = options['size'] ? options.delete('size') : 'original'
    asset.thumbnail(size) rescue nil
  end
  
  desc %{
    Renders a link to the asset. If the asset is an image, the <code>size</code> attribute can be used to 
    generate a link to that size. 
    
    *Usage:* 
    <pre><code><r:asset:link [name="asset name" or id="asset id"] [size="icon|thumbnail"] /></code></pre>
  }
  tag 'asset:link' do |tag|
    asset, options = asset_and_options(tag)
    size = options['size'] ? options.delete('size') : 'original'
    text = options['text'] || asset.title
    anchor = options['anchor'] ? "##{options.delete('anchor')}" : ''
    attributes = options.inject('') { |s, (k, v)| s << %{#{k.downcase}="#{v}" } }.strip
    attributes = " #{attributes}" unless attributes.empty?
    text = tag.double? ? tag.expand : text
    url = asset.thumbnail(size)
    %{<a href="#{url  }#{anchor}"#{attributes}>#{text}</a>} rescue nil
  end
    
private
  def asset_and_options(tag)
    options = tag.attr.dup
    [find_asset(tag, options), options]
  end
  
  def find_asset(tag, options)
    tag.locals.asset ||= if title = (options.delete('name') || options.delete('title'))
      Asset.find_by_title(title)
    elsif id = options.delete('id')
      Asset.find_by_id(id)
    end
    tag.locals.asset || raise(TagError, "Asset not found.")
  end
  
  def assets_find_options(tag)
    attr = tag.attr.symbolize_keys
    extensions = attr[:extensions] && attr[:extensions].split('|') || []
    conditions = unless extensions.blank?
      # this is soon to be removed in favour of asset types
      [ extensions.map { |ext| "assets.asset_file_name LIKE ?"}.join(' OR '), 
        *extensions.map { |ext| "%.#{ext}" } ]
    else
      nil
    end
    
    by = attr[:by] || 'page_attachments.position'
    order = attr[:order] || 'asc'
    
    options = {
      :order => "#{by} #{order}",
      :limit => attr[:limit] || nil,
      :offset => attr[:offset] || nil,
      :conditions => conditions
    }
  end
  
  def swf_embed_markup(url, dimensions, fallback_content)
    width, height = dimensions
    %{<!--[if !IE]> -->
      <object type="application/x-shockwave-flash" data="#{url}" width="#{width}" height="#{height}">
    <!-- <![endif]-->
    <!--[if IE]>
      <object width="#{width}" height="#{height}"
        classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"
        codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,0,0">
        <param name="movie" value="#{url}" />
    <!-->
    #{fallback_content}
      </object>
    <!-- <![endif]-->}
  end
end

