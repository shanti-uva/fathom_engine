class AccountMailer < ActionMailer::Base

  if APPLICATION_DOMAIN == 'shanti.virginia.edu'
    SERVICE_NAME = 'SHANTI at the University of Virginia'
  else
    SERVICE_NAME = 'THL Interconnections'
  end

  default :from => 'thl@collab.itc.virginia.edu', :sent_on => Time.now
  
  def request_full( person, request_text )
    @subject    = "#{person.name} requests full access"
    @body       = { 'person' => person, 'request_text' => request_text }
    @recipients = FATHOM_CONTACT_ADDRESS
    @from       = FATHOM_NO_REPLY_ADDRESS
    @sent_on    = Time.now
    @headers    = {}
  end
  
  def access_level_changed( user )
    @subject    = "#{SERVICE_NAME}: access level changed"
    @body       = { 'user' => user }
    @recipients = "#{user.person.name} <#{user.email}>"
    @from       = FATHOM_NO_REPLY_ADDRESS
    @sent_on    = Time.now
    @headers    = {}
  end
  
  def access_granted( user )
    @subject    = "#{SERVICE_NAME}: access granted"
    @body       = { 'user' => user }
    @recipients = "#{user.person.name} <#{user.email}>"
    @from       = FATHOM_NO_REPLY_ADDRESS
    @sent_on    = Time.now
    @headers    = {}
  end

  def notify_pending( user )
    @subject    = "#{SERVICE_NAME}: new user waiting for approval"
    @body       = { 'user' => user }
    @recipients = FATHOM_CONTACT_ADDRESS
    @from       = FATHOM_NO_REPLY_ADDRESS
    @sent_on    = Time.now
    @headers    = {}
  end


  def invite_user( invitee, inviter, project )
    debugger
    #@subject    = "#{inviter.person.name} has invited you to join #{SERVICE_NAME}."
    @body       = { 'inviter' => inviter, 'invitee' => invitee, 'project' => project }
    #@recipients = "#{invitee[:full_name]} <#{invitee[:email]}>"
    #@from       = FATHOM_NO_REPLY_ADDRESS
    #@sent_on    = Time.now
    @headers    = {}
    mail(:to => "#{invitee[:full_name]} <#{invitee[:email]}>", :subject => "#{inviter.person.name} has invited you to join #{SERVICE_NAME}.")
  end

  def forgot_password( user )
    @subject    = "Password reset for #{SERVICE_NAME}"
    @body       = { 'user' => user }
    @body[:url]  = "http://#{APPLICATION_DOMAIN}/reset/#{user.reset_code}"
    @body[:service_name] = SERVICE_NAME
    @recipients = "#{user.person.name} <#{user.email}>"
    @from       = FATHOM_NO_REPLY_ADDRESS
    @sent_on    = Time.now
    @headers    = {}
  end
end
