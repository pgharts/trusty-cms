require 'digest/sha1'

class User < ActiveRecord::Base
  has_many :pages, :foreign_key => :created_by_id

  # Default Order
  default_scope {order("name")}

  # Associations
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'

  # Validations
  validates_uniqueness_of :login

  validates_confirmation_of :password, :if => :confirm_password?

  validates_presence_of :name, :login
  validates_presence_of :password, :password_confirmation, :if => :new_record?


  validates_length_of :name, :maximum => 100, :allow_nil => true
  validates_length_of :login, :within => 3..40, :allow_nil => true
  validates_length_of :password, :within => 5..40, :allow_nil => true, :if => :validate_length_of_password?
  validates_length_of :email, :maximum => 255, :allow_nil => true

  attr_writer :confirm_password

  def has_role?(role)
    respond_to?("#{role}?") && send("#{role}?")
  end

  def sha1(phrase)
    Digest::SHA1.hexdigest("--#{salt}--#{phrase}--")
  end

  def self.authenticate(login_or_email, password)
    user = where(["login = ? OR email = ?", login_or_email, login_or_email]).first
    user if user && user.authenticated?(password)
  end

  def authenticated?(password)
    self.password == sha1(password)
  end

  def after_initialize
    @confirm_password = true
  end

  def confirm_password?
    @confirm_password
  end

  def remember_me
    update_attribute(:session_token, sha1(Time.now + TrustyCms::Config['session_timeout'].to_i)) unless self.session_token?
  end

  def forget_me
    update_attribute(:session_token, nil)
  end

  def send_password_reset
    generate_token(:password_reset_token)
    update_attribute(:password_reset_sent_at, Time.zone.now)
    PasswordMailer.password_reset(self).deliver_now
  end

  private

  def generate_token(column)
    self[column] = SecureRandom.urlsafe_base64 if User.exists?(column => self[column])
  end

  def validate_length_of_password?
    new_record? or not password.to_s.empty?
  end

  before_create :encrypt_password
  def encrypt_password
    self.salt = Digest::SHA1.hexdigest("--#{Time.now}--#{login}--sweet harmonious biscuits--")
    self.password = sha1(password)
  end

  before_update :encrypt_password_unless_empty_or_unchanged
  def encrypt_password_unless_empty_or_unchanged
    user = self.class.find(self.id)
    case password
    when ''
      self.password = user.password
    when user.password
    else
      encrypt_password
    end
  end

end
