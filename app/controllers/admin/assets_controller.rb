class Admin::AssetsController < Admin::ResourceController
  paginate_models(:per_page => 50)
  COMPRESS_FILE_TYPE = ["image/jpeg", "image/png", "image/gif", "image/svg+xml"]

  def index
    assets = Asset.order("created_at DESC")
    @page = Page.find(params[:page_id]) if params[:page_id]

    @term = params[:search] || ''
    assets = assets.matching(@term) if @term && !@term.blank?

    @types = params[:filter] ? params[:filter].split(",") : []
    if @types.include?('all')
      params[:filter] = nil
    elsif @types.any?
      assets = assets.of_types(@types)
    end

    @assets = paginated? ? assets.paginate(pagination_parameters) : assets.all
    respond_to do |format|

      format.js {
        @page = Page.find_by_id(params[:page_id])
        render :partial => 'asset_table', :locals => {:with_pagination => true}
      }
      format.html {
        render
      }
    end
  end

  def create
    @assets, @page_attachments = [], []
    compress = current_site.try(:compress) ? current_site.compress : true
    asset_params[:asset][:asset].to_a.each do |uploaded_asset|
      if uploaded_asset.content_type == "application/octet-stream"
        flash[:notice] = "Please only upload assets that have a valid extension in the name."
      else
        uploaded_asset = compress(uploaded_asset) if $kraken.api_key.present? && COMPRESS_FILE_TYPE.include?(uploaded_asset.content_type) && compress
        @asset = Asset.create(:asset => uploaded_asset, :caption => asset_params[:asset][:caption])
        if params[:for_attachment]
          @page = Page.find_by_id(params[:page_id]) || Page.new
          @page_attachments << @page_attachment = @asset.page_attachments.build(:page => @page)
        end
        @assets << @asset
      end
    end
    if asset_params[:for_attachment]
      render :partial => 'admin/page_attachments/attachment', :collection => @page_attachments
    else
      response_for :create
    end
  end

  def refresh
    if asset_params[:id]
      @asset = Asset.find(params[:id])
      @asset.asset.reprocess!
      flash[:notice] = t('clipped_extension.thumbnails_refreshed')
      redirect_to edit_admin_asset_path(@asset)
    else
      render
    end
  end

  only_allow_access_to :regenerate,
    :when => [:admin],
    :denied_url => { :controller => 'admin/assets', :action => 'index' },
    :denied_message => 'You must have admin privileges to refresh the whole asset set.'

  def regenerate
    Asset.all.each { |asset| asset.asset.reprocess! }
    flash[:notice] = t('clipped_extension.all_thumbnails_refreshed')
    redirect_to admin_assets_path
  end

private
  def compress(uploaded_asset)
    data = $kraken.upload(uploaded_asset.tempfile.path, 'lossy' => true)
    File.write(uploaded_asset.tempfile, open(data.kraked_url).read, { :mode => 'wb' })
    uploaded_asset
  end

  def asset_params
    params.permit(:id, :for_attachment, :asset => [:caption, :for_attachment, :asset => []])
  end
end
