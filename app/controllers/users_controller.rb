require 'json'

class UsersController < ApplicationController
  
  ##layout "simpler_main"
  #layout "main"
  protect_from_forgery :except => :update
  
  before_filter :login_required, :only => [ :index, :update, :link_netbadge ]
  before_filter :redirect_current_user, :only=>[:new, :create]
  before_filter :main_nav
  
  # render new.rhtml
  def new    
    # should be checking for "pubcookie_s_DigitalHumanitiesPortal" cookie?f
    oi_url = session['OPENID_url'] #params[:identity_url]
    #ru = session['REMOTE_USER']
    #unless ru.blank?
    #  @user ||= User.new
    #  @user.access_level = 'Full'
    #  @user.netbadgeid=ru
    #  @user.email = "#{ru}@virginia.edu"
    #end
    unless oi_url.blank?
      @user ||= User.new
      @user.access_level = 'Pending'
      @user.identity_url = oi_url
      @identity_url = oi_url
      @user.email = session['OPENID_email'] #params[:email]  
      @user.first_name =  session['OPENID_fullname'] #params[:fullname]
    end
    @login_enabled = true
    @nav_enabled = true
    @current_style = :gallery
  end
  
  def new_openid
    session['OPENID_url'] = nil
    session['OPENID_fullname'] = nil
    session['OPENID_email'] = nil
    session['REMOTE_USER'] = nil
    @current_style = :gallery
  end
  
  # render new_netbadge.rhtml
  def new_netbadge
    ru = session['REMOTE_USER']
    @current_style = :gallery
    unless ru.blank?
      @user ||= User.new
      @user.access_level = 'Full'
      @user.netbadgeid=ru
      @user.email = "#{ru}@virginia.edu"
    else
      redirect_to home_page_url
    end
    @login_enabled = true
    @nav_enabled = true
  end
  
  def index
    unless admin?
      render :nothing => true
      return
    end
    @current_style = :gallery
    @uses_admin_grid = true
    @current_nav_item = :admin
    #@users = User.find(:all, :order => "access_level DESC")
    @users = User.order("access_level DESC")
    render :action => 'index'#, :layout => 'main'
  end
  
  # GET /users/1
  # GET /users/1.xml
  def show
    @current_style = :gallery
    @user = User.find(params[:id])
    respond_to do |format|
      format.html # show.rhtml
    end
  end
  
  # GET /users/1;edit
  def edit
    @current_style = :gallery
    @user = User.find(params[:id])
  end
 
  def update
    user = User.find(params[:id])
    access_level = params[:user][:access_level]
    background = params[:user][:background]
    private_profile = params[:user][:private_profile]
    if !private_profile.blank?
      user.private_profile = private_profile
    end
    if !background.blank?
       user.background = background
    end
    unless access_level == 'Root'
         user.adjust_access_level(access_level)
    end
    user.save!
    respond_to do |format|
      format.html { redirect_to user_url(user) }
    end
  end
 
  #def update
  #  unless admin?
  #    render :nothing => true
  #    return
  #  end
  #  
  #  # FUTURE: Should this be in the model on a :before_destroy hook?
  #  # Open Solr connection.
  #  solr = SolrSearch.new(SOLR_URL)
  #  
  #  data = JSON.parse params[:data]
  #  data.each do |field|
  #    
  #    user = User.find(field['id'].to_i)
  #    access_level = field['access']
  #    # make sure user has permission level to make this change
  #    unless access_level == 'Root' || ( access_level == 'Admin' and not root?() )
  #      user.adjust_access_level(access_level)
  #      user.banned = field['banned']
  #
  #      # Remove Solr document for this user.
  #      solr.remove_document(user.person.solr_entity_id)
  #
  #      # Destroy this record if we asked the user to be destroyed. Otherwise, save it.
  #      field['destroy'] ? user.destroy : user.save!
  #    end
  #  end
  #
  #  # Commit changes back to Solr.
  #  solr.commit
  #
  #  render :nothing => true
  #end
  
  def link_netbadge
    redirect_to(me_path) if session['REMOTE_USER'].blank?
    # make changes to user record
    #link_account_to_netbadgeid()
    current_user.netbadgeid = session['REMOTE_USER']
    upgrade_to_full_access()
    current_user.save!
    # restart the session as a netbadge based session
    #logout_session()
    # redirect to user profile in http protocol
    redirect_to( me_path )
  end
  
  def validate_openid
    if using_open_id?
      open_id_authentication(params[:openid_url])
    else
      redirect_to(signup_url)
      return
    end
  end
  
  def create
    cookies.delete :auth_token
    recaptcha_verified = false
    #blacklist = Blacklist.find(:first, :conditions => [ "email = ?", params[:user][:email]]  )
    blacklist = Blacklist.where("email = ?", params[:user][:email]).first
    if !blacklist.blank?
      # the user is in the blacklist, so is turned down
      #update No. of attempts, and Last Attempt date of black list record
      if blacklist.attempts.blank?
        blacklist.attempts = 1
      else  
        blacklist.attempts = blacklist.attempts + 1
      end
      blacklist.last_attempt = Time.now
      blacklist.save! 
      redirect_to(turned_down_url)    
      return
    end  
    
      @user = User.new({ :login => params[:user][:email], 
          :email => params[:user][:email],
          :background => params[:user][:background],
          :identity_url => params[:user][:identity_url],
          :netbadgeid => session['REMOTE_USER'], 
          :password => params[:user][:password],
          :password_confirmation => params[:user][:password_confirmation] })

      # If the user has a netbadge id, give them full access. Regular Users and OpenId users will have 'Pending' access_level
      @user.access_level = @user.netbadgeid.blank? ? 'Pending' : 'Full'
      #@user.access_level = 'Full' #temporarily disabled filter for a week.
      
      @person = @user.create_person
      @person.name = "#{params[:user][:first_name]} #{params[:user][:last_name]}"    

      @person.create_person_profile()
      @person.person_profile.first_name = params[:user][:first_name]
      @person.person_profile.last_name = params[:user][:last_name]
      @person.person_profile.title = params[:user][:title]
      @person.person_profile.professional_profile = params[:user][:professional_profile]

      if @user.netbadgeid.blank? and @user.identity_url.blank? # session['REMOTE_USER'].blank? # Needs Recaptcha since it's a regular user
        if verify_recaptcha(:model => @user, :message => 'Recaptcha words are Incorrect!') && @user.save
          if @user.access_level == 'Pending'
            @user.notify_pending_level()
              redirect_to(signed_up_url)
          else
            self.current_user = @user
            flash[:notice] = "Thanks for signing up!"
            redirect_to(me_url)
          end
        else
          self.send(:new)
          render :action => 'new'
        end
      else #doesn't use recaptcha since uses NetbadgeId or OpenId
        if @user.save
          if @user.access_level == 'Pending' #OpenId user
            @user.notify_pending_level()
            redirect_to(signed_up_url)
          else
            self.current_user = @user
            flash[:notice] = "Thanks for signing up!"
            redirect_to(me_url)
          end
        else
          self.send(:new)
          render :action => 'new'
        end
      end  
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    unless admin?
      render :nothing => true
      return
    end
    
    user = User.find(params[:id])
    # Open Solr connection.
    solr = SolrSearch.new(SOLR_URL)
    # Remove Solr document for this user.
    solr.remove_document(user.person.solr_entity_id)
    
    user.destroy
    
    # Commit changes back to Solr.
    solr.commit

    respond_to do |format|
      format.html { redirect_to users_url }
      #format.xml  { head :ok }
    end
  end
  
  def pending
     @current_style = :gallery
  end

  def rejected
    @current_nav_item = :banned
    @current_style = :gallery
  end
  
  def invalid_code
    @current_style = :gallery
  end
  
  def forgot_password
    @current_style = :gallery
    if request.post?
      user = User.find_by_email(params[:user][:email])
      if user
        if user.netbadgeid.blank? and user.identity_url.blank?
          user.create_reset_code
          flash[:notice] = "Reset code sent to #{user.email}"
          render :action => :code_generated
        else
          if !user.netbadgeid.blank?
            flash[:notice] = "Sorry, but you have entered a University of Virginia email address. This 'forgot your password?' link is only for non-UVa email addresses. If you need to change your UVa email password, please consult http://itc.virginia.edu/accounts/changelost.html"
          else
            flash[:notice] = "Sorry, but your account has an open ID registered. If you want to change your password, you need to consult your open ID provider"
          end
        end
      else
        flash[:notice] = "We are sorry, but the email #{params[:user][:email]} is not currently in our records. The email address must be an exact match for the one you originally entered. Please try variations on the email address, such as the aliases, or variations on what appears after the @ sign; or try other email addresses you may have used. If nothing works, contact us using the link at the bottom of the page."
      end
      #redirect_back_or_default('/')
    end
  end
  
  def reset_password
    @current_style = :gallery
    @user = User.find_by_reset_code(params[:reset_code]) unless params[:reset_code].nil?
    if request.post?
      if @user.blank?
        #redirect_back_or_default('/')
        render :action => :invalid_code
      else
        if @user.reset_password_code_until  && Time.now < @user.reset_password_code_until 
          if @user.update_attributes(:password => params[:user][:password], :password_confirmation => params[:user][:password_confirmation])
            #self.current_user = @user
            @user.delete_reset_code
            flash[:notice] = "Password reset successfully for #{@user.email}"
            redirect_back_or_default('/')
          else
            render :action => :reset_password
          end
        else #password_code has expired
          #redirect_back_or_default('/')
          render :action => :invalid_code      
        end 
      end   
    end
    if @user.blank?
      #redirect_back_or_default('/')
      render :action => :invalid_code
    end
  end
  
  def code_generated
    @current_style = :gallery
  end
  
  def ban_user
    user = User.find(params[:id])
    #user.banned = true
    #user.save!
    # Move user to blacklist
    @blacklist = Blacklist.new({ :email => user.email,
        :first_name => user.person.person_profile.first_name,
        :last_name => user.person.person_profile.last_name,
        :attempts => 1,
        :last_attempt => Time.now })
    @blacklist.save

    # Destroy user that is being banned
    solr = SolrSearch.new(SOLR_URL)
    solr.remove_document(user.person.solr_entity_id)
    user.destroy
    solr.commit
    
    respond_to do |format|
      format.html { redirect_to users_url }
    end
  end
  
  def unban_user
    user = User.find(params[:id])
    user.banned = false
    user.save!
    respond_to do |format|
      format.html { redirect_to users_url }
    end
  end
  
  def remove_user
    person = Person.find(params[:id])
    project = Project.find(params[:entity])
    
    # prevent an authenticated user from destroying someone else's stuff
    unless content_author?(person)
      redirect_to(person)
      return
    end

    Relationship.remove_person_from_project(person,project)

    respond_to do |format|
      format.html {
        flash[:notice] = "#{person.name} is no longer a member of #{project.name}"
        redirect_to(person)
      }
    end
  end

  def testmail
    AccountMailer.registration_confirmation.deliver
    redirect_to(root_path)
  end

  protected
  
  #
  # This is used to prevent an existing user from signing up etc..
  #
  def redirect_current_user
    if self.current_user.is_a?(User)
      redirect_to me_path
    end
  end
  
  #this is used to authenticate the openid_url before signup
  def open_id_authentication(openid_url)
     authenticate_with_open_id(openid_url, :required => [:nickname, :email], :optional => :fullname) do |result, identity_url, registration|
       if result.successful?
         @user = User.find_by_identity_url(identity_url)
         if @user.nil?
           session['OPENID_url'] = identity_url
           if !registration['fullname'].nil?
             session['OPENID_fullname'] = registration['fullname']
             fullname = registration['fullname']
           else
             if !registration['nickname'].nil?
               session['OPENID_fullname'] = registration['nickname']
               fullname = registration['nickname']
             end
           end
           if !registration['email'].nil?
             session['OPENID_email'] = registration['email']
             email = registration['email']
           end
           #@user.save(false)
           redirect_to signup_path
           #redirect_to  :controller => 'users', :action => 'new', :identity_url => identity_url, :email => email, :fullname => fullname
         else
             failed_authentication "There's an account with this OpenId URL."
         end
       else
         failed_authentication result.message
       end
     end
   end
   
   def failed_authentication( message = "OpenId Authentication Failure. Please try again.")
     flash[:notice] = message
     redirect_to(signup_openid_path )
   end
  
  protected
  def main_nav
    @current_nav_item = :users
    @login_enabled = true
    @nav_enabled = true
    @profile_view = true        
  end  
end
