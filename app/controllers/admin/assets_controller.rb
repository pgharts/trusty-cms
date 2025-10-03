class Admin::AssetsController < Admin::ResourceController
  paginate_models(per_page: 50)
  COMPRESS_FILE_TYPE = ['image/jpeg', 'image/png', 'image/gif', 'image/svg+xml'].freeze
  APPROVED_CONTENT_TYPES = Asset::APPROVED_CONTENT_TYPES

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

  def uploader
    @page_attachments = []
    result = process_uploaded_asset(asset_params[:upload])

    if result[:asset]
      @asset = result[:asset]
      if params[:for_attachment]
        @page = Page.find_by_id(params[:page_id]) || Page.new
        @page_attachments << (@page_attachment = @asset.page_attachments.build(page: @page))
      end

      render json: { url: @asset.asset.url }
    else
      flash[result.fetch(:flash_type, :error)] = result[:error]
      render json: { error: result[:error] }, status: result.fetch(:status, :unprocessable_entity)
    end
  end

  def create
    @assets = []
    @page_attachments = []
    uploads = Array(asset_params.dig('asset', 'asset')).reject(&:blank?)

    uploads.each do |uploaded_asset|
      result = process_uploaded_asset(uploaded_asset)

      if result[:asset]
        @asset = result[:asset]
        if params[:for_attachment]
          @page = Page.find_by_id(params[:page_id]) || Page.new
          @page_attachments << (@page_attachment = @asset.page_attachments.build(page: @page))
        end
        @assets << @asset
      else
        flash[result.fetch(:flash_type, :error)] = result[:error]
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

  def process_uploaded_asset(uploaded_asset)
    return failure_response('No file uploaded.', :unprocessable_entity, :error) unless uploaded_asset.present?

    if uploaded_asset.content_type == 'application/octet-stream'
      return failure_response('Please only upload assets that have a valid extension in the name.', :unprocessable_entity, :notice)
    end

    unless APPROVED_CONTENT_TYPES.include?(uploaded_asset.content_type)
      return failure_response('Unsupported file type.', :unsupported_media_type, :error)
    end

    processed_upload = maybe_compress(uploaded_asset)
    asset = Asset.create(asset: processed_upload, caption: '')

    if asset.valid?
      set_owner_or_editor(asset)
      { asset: asset }
    else
      failure_response(asset.errors.full_messages.first, :unprocessable_entity, :error)
    end
  end

  def maybe_compress(uploaded_asset)
    should_compress?(uploaded_asset.content_type) ? compress(uploaded_asset) : uploaded_asset
  end

  def should_compress?(content_type)
    $kraken.api_key.present? && COMPRESS_FILE_TYPE.include?(content_type) && compression_enabled?
  end

  def compression_enabled?
    current_site.try(:compress).nil? ? true : current_site.compress
  end

  def failure_response(message, status, flash_type)
    { error: message, status: status, flash_type: flash_type }
  end

  def compress(uploaded_asset)
    require 'open-uri'
    data = $kraken.upload(uploaded_asset.tempfile.path, 'lossy' => true)
    new_asset = data.success ? data.kraked_url : uploaded_asset.tempfile.path
    File.write(uploaded_asset.tempfile, URI.open(new_asset).read, mode: 'wb')
    uploaded_asset
  end

  def set_owner_or_editor(asset = @asset)
    return unless asset

    asset.created_by_id = current_user.id
    asset.updated_by_id = current_user.id
    asset.save! if asset.id.present?
  end

  def asset_params
    params.permit(:id, :upload, :for_attachment, asset: [:for_attachment, { asset: [] }])
  end
end
