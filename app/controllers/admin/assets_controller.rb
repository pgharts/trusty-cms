class Admin::AssetsController < Admin::ResourceController
  paginate_models(per_page: 50)
  COMPRESS_FILE_TYPE = ['image/jpeg', 'image/png', 'image/gif', 'image/svg+xml'].freeze

  def index
    assets = Asset.order('created_at DESC')
    @page = Page.find(params[:page_id]) if params[:page_id]
    @term = assets.ransack(params[:search] || '')
    assets = @term.result(distinct: true)

    @types = params[:filter] ? params[:filter].split(',') : []
    if @types.include?('all')
      params[:filter] = nil
    elsif @types.any?
      assets = assets.of_types(@types)
    end

    @assets = paginated? ? assets.paginate(pagination_parameters) : assets.all

    respond_to do |format|
      format.js do
        @page = Page.find_by_id(params[:page_id])
        render partial: 'asset_table', locals: { with_pagination: true }
      end
      format.html do
        render
      end
    end
  end

  def create
    @assets = []
    @page_attachments = []
    compress = current_site.try(:compress).nil? ? true : current_site.compress
    asset_params[:asset][:asset].reject(&:blank?).each do |uploaded_asset|
      if uploaded_asset.content_type == 'application/octet-stream'
        flash[:notice] = 'Please only upload assets that have a valid extension in the name.'
      else
        uploaded_asset = compress(uploaded_asset) if $kraken.api_key.present? && COMPRESS_FILE_TYPE.include?(uploaded_asset.content_type) && compress
        @asset = Asset.create(asset: uploaded_asset, caption: asset_params[:asset][:caption])
        if @asset.valid?
          set_owner_or_editor
          if params[:for_attachment]
            @page = Page.find_by_id(params[:page_id]) || Page.new
            @page_attachments << @page_attachment = @asset.page_attachments.build(page: @page)
          end
          @assets << @asset
        else
          error = @asset.errors.first.message
          flash[:error] = error
        end
      end
    end

    if asset_params[:for_attachment]
      render partial: 'admin/page_attachments/attachment', collection: @page_attachments
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

  private

  def compress(uploaded_asset)
    require 'open-uri'
    data = $kraken.upload(uploaded_asset.tempfile.path, 'lossy' => true)
    new_asset = data.success ? data.kraked_url : uploaded_asset.tempfile.path
    File.write(uploaded_asset.tempfile, URI.open(new_asset).read, mode: 'wb')
    uploaded_asset
  end

  def set_owner_or_editor
    @asset.created_by_id = current_user.id
    @asset.updated_by_id = current_user.id
    @asset.save! if @asset.id.present?
  end

  def asset_params
    params.permit(:id, :for_attachment, asset: [:for_attachment, { asset: [] }])
  end
end