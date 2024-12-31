class PageStatusController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:refresh]
  skip_before_action :authenticate_user!, only: [:refresh]
  before_action :authenticate_bearer_token

  def refresh
    pages = Page.where(status_id: Status[:scheduled].id)

    updated_pages = []
    remaining_scheduled_page_ids = []

    pages.each do |page|
      if page.published_at <= Time.now
        page.update(status_id: Status[:published].id)
        updated_pages << page.id
      else
        remaining_scheduled_page_ids << page.id
      end
    end

    if updated_pages.any?
      render json: {
        message: "Successfully updated status of #{updated_pages.count} #{'page'.pluralize(updated_pages.count)}.",
        updated_page_ids: updated_pages,
        remaining_scheduled_page_ids: remaining_scheduled_page_ids
      }, status: :ok
    else
      render json: {
        message: "No scheduled pages matched the criteria for status refresh.",
        remaining_scheduled_page_ids: remaining_scheduled_page_ids
      }, status: :ok
    end
  end

  private

  def authenticate_bearer_token
    provided_token = request.headers['Authorization']&.split(' ')&.last

    if provided_token.blank?
      render json: { error: 'Missing Bearer Token' }, status: :unauthorized
      return
    end

    expected_token = Rails.application.credentials[:trusty_cms][:page_status_bearer_token]

    unless ActiveSupport::SecurityUtils.secure_compare(provided_token, expected_token)
      render json: { error: 'Invalid Bearer Token' }, status: :unauthorized
    end
  end
end
