class PageField < ActiveRecord::Base
  attr_accessible :name, :content
  validates_presence_of :name
end
