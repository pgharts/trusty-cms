class Admin::PageFieldsController < Admin::ResourceController
  def create
    self.model.attributes = page_fields_params
    @controller_name = 'page'
    @template_name = 'edit'
    render :partial => "page_field", :object => model,
      :locals => { :page_field_counter => params[:page_field_counter].to_i}
  end

  private

  def page_fields_params
    params.require(:page_field).permit(:name, :content, :page_id)
  end

end
