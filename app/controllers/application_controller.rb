# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  uses_tiny_mce :options => { 
  								:theme => 'advanced',
  								:editor_selector => 'mceEditor2',
  								:width => '550px',
  								:height => '220px',
  								:strict_loading_mode => 'true',
  								:theme_advanced_resizing => 'true',
  								:theme_advanced_toolbar_location => 'top', 
  								:theme_advanced_toolbar_align => 'left',
  								:theme_advanced_buttons1 => %w{fullscreen separator bold italic underline strikethrough separator undo redo separator link unlink template formatselect code},
  								:theme_advanced_buttons2 => %w{cut copy paste separator pastetext pasteword separator bullist numlist outdent indent separator  justifyleft justifycenter justifyright justifiyfull separator removeformat  charmap },
  								:theme_advanced_buttons3 => [],
  								:plugins => %w{contextmenu paste media fullscreen template noneditable  },				
  								:template_external_list_url => '/templates/templates.js',
  								:noneditable_leave_contenteditable => 'true',
  								:theme_advanced_blockformats => 'p,h1,h2,h3,h4,h5,h6'
  								}
  
  rescue_from ActionController::InvalidAuthenticityToken, :with => :bad_token
  								
  helper :all # include all helpers, all the time
  
  include AuthenticatedSystem
  include FathomAuthorizationSystem
  include ExceptionNotification::Notifiable
  include Spelling
  
  before_filter :dump_env_and_session
  before_filter :redirect_https_to_http
  #before_filter :auto_netbadge_login
  
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery :secret => '91f4ae4c2d9b8bb58461c68ee2ee27c7'
  
  
  def spellchecker 
      language, words, method = params[:params][0], params[:params][1], params[:method] unless params[:params].blank?
      return render :nothing => true if language.blank? || words.blank? || method.blank?
      headers["Content-Type"] = "text/plain"
      headers["charset"] = "utf-8"
      suggestions = check_spelling(words, method, language)
      results = {"id" => nil, "result" => suggestions, "error" => nil}
      render :json => results
            
      #@headers['Content-Type'] = 'text/xml' 
      #@headers['charset'] = 'utf-8' 
      #suggestions = check_spelling(params[:params][1], params[:method], params[:params][0])
      #results = {”id” => nil, “result” => suggestions, ‘error’ => nil}
      #render :text => results.to_json
      #return
  end
  
  def bad_token
    flash[:notice] = "That session has expired. Please log in again."
    redirect_to login_page_path #home_page_url
  end
  
  protected
  
  #
  # If:
  #   there is a netbadgeid available
  #   there is no current_user
  #   and a user exists by the netbadgeid value...
  # send them to their profile page (the "me" route)
  #
  def auto_netbadge_login
    if self.netbadgeid && ! self.current_user && (u=User.find_by_netbadgeid(self.netbadgeid()))
      self.current_user=u
      redirect_to me_path
    end
  end
  
  def dump_env_and_session
    logger.info "REQUEST ENV:
      #{request.env.inspect}
    "
    logger.info "SESSION ENV:
      #{session.inspect}
    "
  end
  
  def redirect_https_to_http
    if request.protocol=='https://' 
      redirect_to(params.merge({:protocol=>'http://'})) if params[:controller]!='sessions' and params[:action]!='netbadge'
      return false
    end
  end

end
