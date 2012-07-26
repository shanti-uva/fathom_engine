class AccountMailer < ActionMailer::Base

  if APPLICATION_DOMAIN == 'shanti.virginia.edu'
    SERVICE_NAME = 'SHANTI at the University of Virginia'
  else
    SERVICE_NAME = 'THL Interconnections'
  end

  default :from => FATHOM_NO_REPLY_ADDRESS
  
  def registration_confirmation
    mail(:to => 'thl@collab.itc.virginia.edu', :subject => "Test using admin@thlib.org")
  end
  
  def request_full( person, request_text )
    @person = person
    @request_text = request_text
    mail(:to => FATHOM_CONTACT_ADDRESS, :subject => "#{person.name} requests full access")
  end
  
  def access_level_changed( user )
    @user = user
    mail(:to => "#{user.person.name} <#{user.email}>", :subject => "#{SERVICE_NAME}: access level changed")
  end
  
  def access_granted( user )
    @user = user
    mail(:to => "#{user.person.name} <#{user.email}>", :subject => "#{SERVICE_NAME}: access granted")
  end

  def notify_pending( user )
    @user = user
    mail(:to => FATHOM_CONTACT_ADDRESS, :subject => "#{SERVICE_NAME}: new user waiting for approval")
  end


  def invite_user( invitee, inviter, project )
    @invitee = invitee
    @inviter = inviter
    @project = project
    mail(:to => "#{invitee[:full_name]} <#{invitee[:email]}>", :subject => "#{inviter.person.name} has invited you to join #{SERVICE_NAME}.")
  end

  def forgot_password( user )
    @user = user
    @url = "http://#{APPLICATION_DOMAIN}/reset/#{user.reset_code}"
    @service_name = SERVICE_NAME
    mail(:to => "#{user.person.name} <#{user.email}>", :subject => "Password reset for #{SERVICE_NAME}")
  end
end
