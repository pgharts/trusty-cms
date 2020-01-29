class User < ActiveRecord::Base
  has_many :pages, :foreign_key => :created_by_id
  self.table_name = 'admins'

  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable

  alias_attribute :created_by_id, :id

  attr_accessor :skip_password_validation

  # Default Order
  default_scope {order('last_name')}

  # Associations
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'

  def has_role?(role)
    case role
    when :admin
      self.admin?
    when :designer
      self.designer?
    when :content_editor
      self.content_editor?  
    else
      false
    end
  end

  def admin?
    self.admin
  end

  def designer?
    self.designer
  end

  def content_editor?
    self.content_editor
  end

  def locale 
    'en'
  end

  def name
    "#{self.first_name} #{self.last_name}"
  end

  def password_required?
    return false if skip_password_validation
    super
  end

end
