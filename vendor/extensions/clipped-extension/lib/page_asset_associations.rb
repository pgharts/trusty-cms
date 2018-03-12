module PageAssetAssociations
  
  #TODO: Turn page_attachments into a generic, polymorphic asset-attachment mechanism
  
  def self.included(base)
    base.class_eval {
      has_many :page_attachments, -> { order 'position desc' }
      has_many :assets,{ :through => :page_attachments},  -> { order 'page_attachments.position ASC' }
      accepts_nested_attributes_for :page_attachments, :allow_destroy => true
    }
  end
  
end