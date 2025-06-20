class PagePart < ActiveRecord::Base
  # Default Order
  default_scope { order('name') }

  # Associations
  belongs_to :page

  has_paper_trail

  # Validations
  validates_presence_of :name
  validates_length_of :name, maximum: 100
  validates_length_of :filter_id, maximum: 25, allow_nil: true

  object_id_attr :filter, TextFilter

  def after_initialize
    self.filter_id ||= TrustyCms::Config['defaults.page.filter'] if new_record?
  end
end
