# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  
  #layout "simpler_main", :except => :new
  
  # render new.rhtml
  def new
    render :layout => nil
  end
  
  #
  # This action is called when a user is trying to login via netbadge...
  # but only should get executed once the NetBadge auth. server initially
  # redirects back to the app.
  #
  def netbadge
    debugger
    # save the REMOTE_USER is the session so we know how this session was authenticated
    # this is used by the sign up action
    session['REMOTE_USER'] = self.netbadgeid
    
    unless self.netbadgeid.blank?
      user = User.find_by_netbadgeid(self.netbadgeid) || User.find_by_email("#{self.netbadgeid}@virginia.edu") || User.find_by_login("#{self.netbadgeid}@virginia.edu")
    end
    
    unless user.nil?
      user.update_attribute(:netbadgeid, self.netbadgeid)
      self.current_user = user
      # go back to regular http
      #render :action => 'link_netbadge'
      redirect_to me_url
    else
      # go back to regular http
      redirect_to signup_netbadge_url
    end
  end
  
  def login_page
    @current_style = :gallery
    if logged_in?
      flash[:notice] = "Logged in successfully"
      redirect_to( me_path )
    end
    @login_enabled = true
    @nav_enabled = true
    #@ssl_secured_page = true
  end
  
  def index
    #open_id_authentication(params[:openid_url])
  end

  def create
    if using_open_id?
      open_id_authentication(params[:openid_url])
    else
      password_authentication(params[:login], params[:password])
    end
  end
  
  def destroy
    logout_session()
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end
  
  protected
  
=begin
  def open_id_authentication(openid_url)
    authenticate_with_open_id(openid_url, :required => [ :nickname, :email ] ) do |result, identity_url, registration|
      if result.successful? 
        @user = User.find_or_initialize_by_identity_url(identity_url)
        if @user.banned
          failed_login "This account has been disabled."
        else
          if @user.new_record?
            #TODO redirect to signup page and populate it with info from open id
            @user.login = registration['nickname']
            @user.email = registration['email']
            @user.save(false)
          end
          self.current_user = @user
          successful_login
        end
      else
        failed_login result.message
      end
    end
  end
=end
  
  def open_id_authentication(openid_url)
     authenticate_with_open_id(openid_url, :required => [:nickname, :email]) do |result, identity_url, registration|
       if result.successful?
         @user = User.find_by_identity_url(identity_url)
         if @user.nil?
           failed_login result.message
         else
           if @user.banned
             failed_login "This account has been disabled."
           else
             if @user.access_level == 'Pending'
               failed_login "This account is not authorized yet."
             else
               self.current_user = @user
               successful_login
             end
           end
         end
       else
         failed_login result.message
       end
     end
   end
  
  def password_authentication( login, password )    
    user = User.authenticate(login, password)
    
    if user and user != :false
      if user.banned
        failed_login "This account has been disabled."
      else
        if user.access_level == 'Pending'
          failed_login "This account is not authorized yet."
        else
          self.current_user = user
          successful_login
        end
      end
    else
        failed_login
    end
  end
  
  def successful_login
    if params[:remember_me] == "1"
      self.current_user.remember_me
      cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
    end
    
    # if they are logging in with an existing account and they have a netbadge id that is not yet associated with an 
    # account, ask them if they wish to associate it    
    if unlinked_netbadgeid_available? 
      @netbadgeid = netbadgeid()
      #@ssl_secured_page = true
      render :action => 'link_netbadge'
    else
      # switch to http on sucessful login
      redirect_to( unguarded_link(me_path) )
      flash[:notice] = "Logged in successfully"
    end
  end
  
  def failed_login( message = "Incorrect e-mail or password. Please try again.")
    flash[:notice] = message
    redirect_to( login_page_path )
  end
  
end
