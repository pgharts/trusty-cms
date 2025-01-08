class PageField < ActiveRecord::Base
  has_paper_trail
  validates_presence_of :name
end
