require 'digest/sha1'
class User < ActiveRecord::Base
  # Virtual attribute for the unencrypted password
  attr_accessor :password
  attr_accessor :first_name, :last_name
  attr_accessor :title, :professional_profile
  
  validates_presence_of     :login, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  
  before_save :encrypt_password
  
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation, :identity_url, :netbadgeid
  
  # The personal profile of this user
  has_one :person, :dependent => :destroy
  has_one :project
  
  validates_associated :person, :message=>' - A First Name and Last Name are required.'
  
  #
  # This is used to override the default association validation error
  #
  def validate_associated_records_for_person
    
  end
  
  
  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end
  
  # Returns an array containing the email addresses of the system admins
  def self.admin_emails()
    admins = find( :all, :conditions => "access_level = 'Admin' or access_level = 'Root'" )
    admins.collect { |admin| "#{admin.person.name} <#{admin.email}>" }
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end
  
  def authenticated_with_netbadge=( authenticated )
    @authenticated_with_netbadge = authenticated
  end
    
  def authenticated_with_netbadge?()
    @authenticated_with_netbadge
  end
  
  def request_full_access( request_text )
    unless self.request_full
      self.request_full = true
      AccountMailer.deliver_request_full(self.person,request_text)
    end         
  end
  
  def adjust_access_level( new_level )
    prev_access_level = self.access_level
    if self.access_level != new_level
      self.access_level = new_level
      self.request_full = false
      if prev_access_level == 'Pending'
        #AccountMailer.deliver_access_granted(self)
        AccountMailer.access_granted(self).deliver
      else
        AccountMailer.access_level_changed(self).deliver
      end
    end
  end

  def notify_pending_level( )
    if self.access_level == 'Pending'
        #AccountMailer.deliver_notify_pending(self)
        AccountMailer.notify_pending(self).deliver
    end
  end
  
  def create_reset_code
    @reset = true
    self.reset_password_code_until = 24.hours.from_now
    self.reset_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    save(false)
    
    AccountMailer.deliver_forgot_password(self)
  end
  
  def recently_reset?
    @reset
  end 
  
  def delete_reset_code
    self.reset_code = nil
    self.reset_password_code_until = nil
    save(false)
  end
  
  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
    
    def password_required?
      return false unless self.netbadgeid.blank?
      return false unless self.identity_url.blank?
      crypted_password.blank? || !password.blank?
    end
    
    
end


# == Schema Info
# Schema version: 20100214201124
#
# Table name: users
#
#  id                        :integer(4)      not null, primary key
#  access_level              :string(255)
#  background                :text
#  banned                    :boolean(1)
#  crypted_password          :string(40)
#  email                     :string(255)
#  identity_url              :string(255)
#  login                     :string(255)
#  netbadgeid                :string(255)
#  private_profile           :boolean(1)
#  remember_token            :string(255)
#  request_full              :boolean(1)
#  reset_code                :string(40)
#  reset_password_code_until :datetime
#  salt                      :string(40)
#  type                      :string(255)
#  created_at                :datetime
#  remember_token_expires_at :datetime
#  updated_at                :datetime