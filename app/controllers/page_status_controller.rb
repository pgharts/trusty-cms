class PageStatusController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:refresh]
  skip_before_action :authenticate_user!, only: [:refresh]
  before_action :authenticate_bearer_token

  def refresh
    pages = Page.where(status_id: Status[:scheduled].id)

    updated_pages, remaining_pages = process_pages(pages)

    render json: refresh_response(updated_pages, remaining_pages), status: :ok
  end

  private

  def authenticate_bearer_token
    provided_token = request.headers['Authorization']&.split(' ')&.last
    expected_token = Rails.application.credentials[:trusty_cms][:page_status_bearer_token]

    if provided_token.blank?
      render json: { error: 'Missing Bearer Token' }, status: :unauthorized and return
    end

    unless ActiveSupport::SecurityUtils.secure_compare(provided_token, expected_token)
      render json: { error: 'Invalid Bearer Token' }, status: :unauthorized
    end
  end

  def process_pages(pages)
    updated_pages = []
    remaining_pages = []

    pages.each do |page|
      page_id = page.id
      if page.published_at && page.published_at <= Time.now
        page.update(status_id: Status[:published].id)
        updated_pages << page_id
      else
        remaining_pages << page_id
      end
    end

    [updated_pages, remaining_pages]
  end

  def refresh_response(updated_pages, remaining_pages)
    if updated_pages.any?
      updated_pages_count = updated_pages.count
      {
        message: "Successfully updated status of #{updated_pages_count} #{'page'.pluralize(updated_pages_count)}.",
        updated_page_ids: updated_pages,
        remaining_scheduled_page_ids: remaining_pages,
      }
    else
      {
        message: 'No scheduled pages matched the criteria for status refresh.',
        remaining_scheduled_page_ids: remaining_pages,
      }
    end
  end
end
