class PeopleController < ApplicationController
  
  #layout "main"
  before_filter :login_required, :except => [ :index, :show ]
  before_filter :main_nav
  
  def profile_tags
    # TODO; provide limit capability (the js autocomplete plugin can send a "limit" param)
    tag = params[:tag_on].to_s
    items = Tagging.search_for(:person_profile, tag, params[:q].to_s, true)
    respond_to do |format|
      format.js { render :json=>items.to_json }
    end
  end
  
  # GET /people
  # GET /people.xml
  def index
    @page_title = "Listing People"
    # only accept valid sort param
    @sort_order = params[:sort] == "profession" || params[:sort] == "name" || params[:sort] == "updated_at" ? params[:sort] : "name"
    case @sort_order
      when "updated_at"
        order_string = "updated_at DESC"
      when "profession"
        order_string = "person_profiles.professional_profile ASC"
      else
        order_string = @sort_order #"name"
    end
    
    @project = Project.find(params[:project_id]) if params[:project_id]
    unless admin?
      #@people = Person.paginate({
      #    :page => params[:page],
      #    :per_page => 20,
      #    :conditions => ["user_id not in (select id from users where access_level = ?) and user_id not in (select id from users where private_profile = ?)", "Pending", true],
      #    :order => order_string,
      #    :include=>[:person_profile, {:person_profile=>:professional_profiles}]
      #    })
      @people = Person.where(["user_id not in (select id from users where access_level = ?) and user_id not in (select id from users where private_profile = ?)", "Pending", true]).order(order_string).includes([:person_profile, {:person_profile=>:professional_profiles}]).paginate(:page => params[:page], :per_page => 20)
      
    else
      #@people = Person.paginate({
      #    :page => params[:page],
      #    :per_page => 20,
      #    :conditions => ["user_id not in (select id from users where access_level = ?)", "Pending"],
      #    :order => order_string,
      #    :include=>[:person_profile, {:person_profile=>:professional_profiles}]
      #  })
      @people = Person.where(["user_id not in (select id from users where access_level = ?)", "Pending"]).order(order_string).includes([:person_profile, {:person_profile=>:professional_profiles}]).paginate(:page => params[:page], :per_page => 20)
      
    end
    
    @profile_view = false    
    @current_style = :gallery
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @people }
    end
  end
  
  def me
    @page_title = "My Profile"
    if APPLICATION_DOMAIN != 'shanti.virginia.edu'
      @current_nav_item = :profile
    else
      @current_nav_item = :uva_profiles #:home
      @current_sub_nav_item = :profile
    end
    @current_style = :details
    @person = current_user.person
    init_line_items(@person)
    @selected_tab = determine_selected_tab(@person)
    @tag_combiner = ProfileTagCombiner.new
    
    @allowed_to_edit = allowed_to_edit?(@person)
    
    if @person.nil?
      @person = Person.new
      render :action => 'new'
    else
      session[:start_node_id] = @person.node_id
      render :action => 'show'
    end
  end
  
  def request_full
    @person = current_user.person    
  end

  def turn_public
    person = Person.find(params[:id])
    if admin? or content_author?(person) #person = current_user.person
      person.user.private_profile = false
      person.user.save
      redirect_to(me_path)
      return
    else
      redirect_to(home_page_path)
      return
    end
  end
  
  def delete
    if allowed_to_delete?(Person.find(params[:id]))
      respond_to do |format|
        format.html {
          redirect_to(logout_path)
        }
      end
      #session.delete
      cookies.delete :auth_token
      reset_session
      User.destroy(current_user.id)
    end
  end

  def submit_request
    person = Person.find(params[:id])
    
    # send e-mail requesting full access 
    person.user.request_full_access(params[:person][:request_text])
    
    respond_to do |format|
      format.html { 
        if person.user.save          
          redirect_to( :action => 'request_sent', :id => person.id )
        else
          flash[:notice] = "Unable to send request."
          redirect_to( :action => 'request_full' )           
        end
      }
    end
  end

  def join_project
    @person = Person.find(params[:id])
    @projects = Project.find(:all) - @person.projects 
    @current_style = :details
  end
  
  def join_tool
    @person = Person.find(params[:id])
    @tools = Tool.find(:all) - @person.tools 
    @current_style = :details
  end
  
  def join_organization
    @person = Person.find(params[:id])
    @organizations = Organization.find(:all) - @person.organizations
    @current_style = :details
  end
  
  def create_project_membership
    @person = Person.find(params[:id])

    # prevent unauthorized access
    unless full_access? 
      redirect_to(@person)
      return
    end

    # nothing selected
    if params['entity'].nil?        
      redirect_to(@person)
      return
    end

    params['entity'].keys.each { |id| 
      project = Project.find(id.to_i)
      relation = Relationship.add_person_to_project(@person,project)
      relation.save!
      project.save!
    }
   
    redirect_to(@person)
  end
  
  def create_tool_membership
    @person = Person.find(params[:id])

    # prevent unauthorized access
    unless full_access? 
      redirect_to(@person)
      return
    end

    # nothing selected
    if params['entity'].nil?        
      redirect_to(@person)
      return
    end

    params['entity'].keys.each { |id| 
      tool = Tool.find(id.to_i)
      relation = Relationship.add_person_to_tool(@person,tool)
      relation.save!
      tool.save!
    }
   
    redirect_to(@person)
  end
  
  def create_organization_membership
    @person = Person.find(params[:id])

    # prevent unauthorized access
    unless full_access? 
      redirect_to(@person)
      return
    end

    # nothing selected
    if params['entity'].nil?        
      redirect_to(@person)
      return
    end

    params['entity'].keys.each { |id| 
      organization = Organization.find(id.to_i)
      relation = Relationship.add_person_to_organization(@person,organization)
      relation.save!
      organization.save!
    }
   
    redirect_to(@person)
  end
   
  def remove_project
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
  
  def remove_tool
    person = Person.find(params[:id])
    tool = Tool.find(params[:entity])

    # prevent an authenticated user from destroying someone else's stuff  
    unless content_author?(person) 
      redirect_to(person) 
      return
    end    
    
    Relationship.remove_person_from_tool(person,tool)

    respond_to do |format|
      format.html { 
        flash[:notice] = "#{person.name} is no longer a member of #{tool.name}" 
        redirect_to(person) 
      }
    end
  end
  
  def remove_organization
    person = Person.find(params[:id])
    organization = Organization.find(params[:entity])

    # prevent an authenticated user from destroying someone else's stuff  
    unless content_author?(person) 
      redirect_to(person) 
      return
    end    
    
    Relationship.remove_person_from_organization(person,organization)

    respond_to do |format|
      format.html { 
        flash[:notice] = "#{person.name} is no longer a member of #{organization.name}" 
        redirect_to(person) 
      }
    end
  end
  
  # GET /people/1
  # GET /people/1.xml
  def show
    @person = Person.find(params[:id])
    if @person.user.private_profile == true
      unless admin? or content_author?(@person) # @person != current_user.person
        redirect_to( home_page_path )
        return
      end
    end
    @page_title = @person.name    
    @allowed_to_edit = allowed_to_edit?(@person)
    init_line_items(@person)
    @current_style = :showview #:details    
    @selected_tab = determine_selected_tab(@person)
    @tag_combiner = ProfileTagCombiner.new
    
    # set the relation browser to show this person
    session[:start_node_id] = @person.node_id

    respond_to do |format|
      format.html
      format.json do
        ## create hash that includes the "thumb" method output
        #json_out={:thumb=>@person.thumb_src, :image=>@person.image_src, :name=>@person.full_name}
        ## populate hash with all column values
        #Person.columns.each{|c|json_out[c.name]=@person.send(c.name)}
        ## render json
        #render :json=>json_out
        
        @nodes = Entity.all
    		@relations = Relationship.relations
        
        #for node in @nodes
        #  json_node = {:id => node.id, :name=> node.name}
        #    #json_out << {:id => node.id, :name=> node.name}
        #end
        
        adjacencies = []
        @person.projects.each do |proj|
          adjacencies << {:nodeTo => "p_"+proj.id.to_s }
        end
        @person.organizations.each do |org|
          adjacencies << {:nodeTo => "o_" + org.id.to_s }
        end
        
        json_out = []
        json_out << {:id=>@person.id, :name=>@person.full_name, :adjacencies=>adjacencies}
        

        @person.projects.each do |proj|
          json_out << {:id => "p_" + proj.id.to_s, :name=> proj.name, :data=>{:parent=>@person.full_name, :relation=>"project"}}
        end
        @person.organizations.each do |org|
          json_out << {:id => "o_" + org.id.to_s, :name=> org.name, :data=>{:parent=>@person.full_name, :relation=>"organization"}}
        end
        #json_out ={:id=>@person.id, :name=>@person.full_name}
        
        render :json=>json_out
        #render :json => Hash.from_xml(render_to_string(:action => 'show.xml.builder'))
        
        
      end
      format.xml  { render :xml => @person }
    end
  end

  # GET /people/new
  # GET /people/new.xml
  def new
    @person = Person.new
    @current_style = :details

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /people/1/edit
  def edit
    @person = Person.find(params[:id])
    @allowed_to_edit = allowed_to_edit?(@person)
    @allowed_to_delete = allowed_to_delete?(@person)
    
    @tag_combiner = ProfileTagCombiner.new
 
    @disciplines = Discipline.find(:all)
    @professional_profiles = ProfessionalProfile.find(:all)
    @uses_text_editor = true    
    init_line_items(@person)
    @current_style = :details
    
    @selected_tab = determine_selected_tab(@person,false)    
    
    # prevent an authenticated user from editing someone else's profile  
    redirect_to(@person) unless content_author?(@person) || admin?
  end

  # GET /people/1/edit
  def dialog
  @current_style = :details
  end
  
  # GET /people/1/edit_picture
  def edit_picture
    @person = Person.find(params[:id])
    @allowed_to_edit = allowed_to_edit?(@person)
    @current_style = :details
    
    # prevent an authenticated user from editing someone else's profile  
    redirect_to(@person) unless allowed_to_edit?(@person) #content_author?(@person)
  end

  # POST /people
  # POST /people.xml
  def create
    @person = Person.new(params[:person])
    @current_style = :details
    
    if !params[:person][:uploaded_data].nil?
      @person.image = Image.new({ :uploaded_data => params[:person][:uploaded_data] })
      @person.image.save
    end
    
    @person.user = current_user
    @person.create_person_profile

    respond_to do |format|
      if @person.save
        flash[:notice] = 'Person was successfully created.'
        format.html { redirect_to(@person) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /people/1
  # PUT /people/1.xml
  def update    
    @person = Person.find(params[:id])
    @current_style = :details
    
    # prevent an authenticated user from editing someone else's profile  
    unless allowed_to_edit?(@person) #content_author?(@person) 
      redirect_to(@person) 
      return
    end
    
    if params[:person][:uploaded_data] != ""
      @person.image = Image.new({ :uploaded_data => params[:person][:uploaded_data] })
      @person.image.save      
      @person.save
    end  
      
    respond_to do |format|
        if @person.update_attributes(params[:person])
          flash[:notice] = 'Person was successfully updated.'
          format.html { redirect_to(@person) }
        else
          format.html { render :action => "edit"  }
        end
    end
      

  end
  
  def update_profile
    @person = Person.find(params[:id])
    @current_style = :details
    @selected_tab = determine_selected_tab(@person,false)
     
    unless @person.person_profile
      @person.create_person_profile()
    end

    #@person.person_profile.update_disciplines(params)
    @person.person_profile.update_professional_profiles(params)
        
    respond_to do |format|
      if @person.person_profile.update_attributes(params[:person_profile])
        flash[:notice] = 'Person was successfully updated.'

        # index the updated profile for searching
        @person.index()
        
        format.html {  redirect_to(url_for( :action => 'show', :id => @person.id, :tab => @selected_tab)) }
      else
        format.html { render :action => "edit", :tab => @selected_tab }
      end
    end   
  end
   
  def positions
    @person = Person.find(params[:id])
    init_line_items(@person)
    #person = @person
    #line_items = person.person_profile.line_items
    #@positions = line_items.select { |item| item.category == 'positions' }
  end 
   
  def credentials
    @person = Person.find(params[:id])
    init_line_items(@person)
  end 
  
  def dynamic_list
    @person = Person.find(params[:id])
    init_line_items(@person)
  end 
  
  def hypertree
    order_string = "name"
      @people = Person.where(["user_id not in (select id from users where access_level = ?)", "Pending"]).order(order_string).includes([:person_profile, {:person_profile=>:professional_profiles}]).paginate(:page => params[:page], :per_page => 20)
      @profile_view = false    
      @current_style = :gallery
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @people }
      end
  end
   
  protected
  def main_nav
    if APPLICATION_DOMAIN != 'shanti.virginia.edu'
      @current_nav_item = :people
    else
      @current_nav_item = :uva_profiles #:home
      #@current_nav_item = :people
      @current_sub_nav_item = :people
    end
    @login_enabled = true
    @nav_enabled = true
    @profile_view = true    
  end
  
  def determine_selected_tab( person, hiding_blanks=true )    
    # if the tab param was given, use that tab, otherwise start on profile
    selected_tab = params[:tab].to_s.blank? ? :profile : params[:tab].to_sym
    
    return selected_tab unless hiding_blanks
    
    # guard against selecting a tab that is blank and therefore not visible
    if selected_tab == :background and (person.person_profile.field_set_blank?(:background) or line_items_blank?(person) )
      return :profile
    elsif person.person_profile.field_set_blank?(selected_tab)
      return :profile
    end
    
    selected_tab  
  end
  
  def line_items_blank?(person)
    @credentials.empty? and @affiliations.empty? and @positions.empty?
  end
  
  def init_line_items(person)
    line_items = person.person_profile.line_items
    @positions = line_items.select { |item| item.category == 'positions' }
    @credentials = line_items.select { |item| item.category == 'credentials' }
    @affiliations = line_items.select { |item| item.category == 'affiliations' }  
  end
        
end
