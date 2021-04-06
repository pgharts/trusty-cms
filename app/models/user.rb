class User < ActiveRecord::Base
  has_many :pages, foreign_key: :created_by_id
  self.table_name = 'admins'

  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  alias_attribute :created_by_id, :id

  attr_accessor :skip_password_validation

  validate :password_complexity

  # Default Order
  default_scope { order('last_name') }

  # Associations
  belongs_to :created_by, class_name: 'User'
  belongs_to :updated_by, class_name: 'User'

  def role?(role)
    case role
    when :admin
      admin?
    when :designer
      designer?
    when :content_editor
      content_editor?
    else
      false
    end
  end

  def admin?
    admin
  end

  def designer?
    designer
  end

  def content_editor?
    content_editor
  end

  def locale
    'en'
  end

  def name
    "#{first_name} #{last_name}"
  end

  def password_required?
    return false if skip_password_validation

    super
  end

  def password_complexity
    return false if password.blank? || password =~ /^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,70}$/

    errors.add :password, 'Complexity requirement not met. Length should be 12 characters and include: 1 uppercase, 1 lowercase, 1 digit and 1 special character.'
  end
end
