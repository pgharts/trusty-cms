module PageAssetAssociations

  def self.included(base)
    base.class_eval {
      has_many :page_attachments, -> { order 'position desc' }
      has_many :assets, -> { order 'page_attachments.position ASC' }, through: :page_attachments
      accepts_nested_attributes_for :page_attachments, :allow_destroy => true
    }
  end

end
