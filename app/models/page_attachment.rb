class PageAttachment < ActiveRecord::Base
  belongs_to :asset
  belongs_to :page
  attr_accessor :selected

  accepts_nested_attributes_for :asset

  acts_as_list :scope => :page_id

  def selected?
    !!selected
  end

  # a small change to the method in acts_as_list so that we don't override
  # the position value if it has already been set (as it usually is for new attachments)
  def add_to_list_bottom
    self[position_column] ||= bottom_position_in_list.to_i + 1
  end

end
