class Admin::ReferencesController < ApplicationController
  def show
    respond_to do |format|
      render_allowed_type(params[:type])
      format.any { render :action => @type, :content_type => "text/html", :layout => false }
    end
  end

  private

  def render_allowed_type(type)
    @type = type
  end
end
