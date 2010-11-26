class HomeController < ApplicationController

  before_filter :login_required, :only => [ :me ]
  before_filter :main_nav
  
  def index
    @featured_projects = Project.find(:all, :order => 'RAND()', :limit => 7 )
    @latest_registrants = Person.find(:all, :order => 'created_at DESC', :limit => 3)
    session[:start_node_id] = "node#{@featured_projects.first.id}" unless @featured_projects.empty?
    #render :layout => 'home'
  end
  
  def relate    
    @start_node_id = session[:start_node_id] ? session[:start_node_id] : "node1"
    @nodes = Entity.find(:all)
		@relations = Relationship.relations
		
    respond_to do |format|
      format.xml  { render :action => 'relate' }
    end
  end
  
  def sniff
    unless root?
      render :nothing => true
      return
    end

    environment = ""
    environment << "<h2>HEADERS</h2>"
    request.headers.keys.each { |key| environment << "#{key} = #{request.headers[key]}<br/>" }    

    environment << "<h2>ENV</h2>"
    request.env.keys.each { |key| environment << "#{key} = #{request.env[key]}<br/>" }    
    render :text => environment
  end
  
  def relationbrowser
    @current_nav_item = :relations 
    @relation_browser_enabled = true
    @login_enabled = true
    @nav_enabled = true
    @relation_browser_full = true
    #render :layout => 'simpler_main'   
  end
  
  protected
  def main_nav
    if APPLICATION_DOMAIN != 'shanti.virginia.edu'
      @current_nav_item = :home
    else
      #@current_nav_item = :uva_profiles
      @current_nav_item = :home
      @current_sub_nav_item = :home
    end
    @current_style = :home
    @login_enabled = true
    @nav_enabled = true
  end
  
end
