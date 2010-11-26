
class PendingUser < User
  
  def self.invite( invited_by, name, email )
    existing_user = User.find_by_email( email )
    if existing_user 
      user.person
    else
      pending_user = PendingUser.new
      pending_user.login = email
      pending_user.email = email      
      pending_user.save!
      person = Person.new
      person.name = name
      person.user = pending_user
      person.save!
      pending_user.send_email_invite(invited_by)
      person
    end
  end
  
  def send_email_invite( invited_by )
    # TODO
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