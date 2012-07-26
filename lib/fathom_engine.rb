
# Fathom-engine
# APPLICATION_DOMAIN = 'shanti.virginia.edu'
APPLICATION_DOMAIN = 'connections.thlib.org'

# Target e-mails for exception handling.
#FATHOM_NO_REPLY_ADDRESS = 'thl@inmotionconsulting.net'
#FATHOM_NO_REPLY_ADDRESS = 'thl@collab.itc.virginia.edu'
FATHOM_NO_REPLY_ADDRESS = 'admin@thlib.org'
FATHOM_CONTACT_ADDRESS = FATHOM_NO_REPLY_ADDRESS

##ExceptionNotifier.sender_address = %Q("Application Error" <#{FATHOM_NO_REPLY_ADDRESS}>)
##ExceptionNotifier.exception_recipients = %w(ys2n@virginia.edu)
ENV['RECAPTCHA_PUBLIC_KEY']  = '6LcK2gkAAAAAANGvhQ8jxCvvlXUulHx1RGUNhrd0'
ENV['RECAPTCHA_PRIVATE_KEY'] = '6LcK2gkAAAAAAGgFUYoC4ogH1xwcNKTfHMCwRVLG'

class String
  def span
    return self
  end      
  alias :s :span
end
