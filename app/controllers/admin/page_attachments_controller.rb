class Admin::PageAttachmentsController < Admin::ResourceController
  helper 'admin/assets'

  def new
    render :partial => 'attachment', :object => model
  end

  def load_model
    begin
      @asset = Asset.find(params[:asset_id])
      @page = page_attachment_params[:page_id].blank? ? Page.new : Page.find_by_id(page_attachment_params[:page_id])
    rescue ActiveRecord::RecordNotFound
      render :nothing => true, :layout => false
    end
    self.model = PageAttachment.new(:asset => @asset, :page => @page)
  end

private
  def page_attachment_params
    params.permit(:asset_id, :page_id)
  end

end
