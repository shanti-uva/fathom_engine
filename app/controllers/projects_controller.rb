class ProjectsController < ApplicationController
  
  #layout "main"
  before_filter :login_required, :except => [ :index, :show ]
  before_filter :main_nav
  
  # GET /projects
  # GET /projects.xml
  def index
    @tag_string = params[:tag_string]
    if !@tag_string.nil?
      @search_projects = get_by_solr_tag(@tag_string)
      # only accept valid sort param
      @sort_order = params[:sort] == "name" || params[:sort] == "updated_at" ? params[:sort] : "name"
      order_string = (@sort_order == "updated_at") ? "updated_at DESC" : @sort_order
      # condition is necessary to fix a rails model caching bug in production mode.
      @projects = Project.paginate :page => params[:page], :per_page => 20, :order => order_string, :conditions => {:id => @search_projects}
    else
      # only accept valid sort param
      @sort_order = params[:sort] == "name" || params[:sort] == "updated_at" ? params[:sort] : "name"
      order_string = (@sort_order == "updated_at") ? "updated_at DESC" : @sort_order
      # condition is necessary to fix a rails model caching bug in production mode.
      @projects = Project.paginate :page => params[:page], :per_page => 20, :order => order_string, :conditions => "type = 'Project'"
    end
    @profile_view = false    
    @current_style = :gallery

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @projects }
    end
  end
  
  # GET /projects/1
  # GET /projects/1.xml
  def show
    @project = Project.find(params[:id])
    session[:start_node_id] = @project.node_id
    session[:hypertree_start_node_id] = 'projects/' + @project.id.to_s + '.json' 
    @current_style = :showview #@current_style = :details
    @selected_tab = determine_selected_tab(@project)    
    @tag_combiner = ProfileTagCombiner.new

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @project }
      format.json do
        ## create hash that includes the "thumb" method output
        #json_out={:thumb=>@project.thumb_src, :image=>@project.image_src}
        ## populate hash with all column values
        #Project.columns.each{|c|json_out[c.name]=@project.send(c.name)}
        ## render json
        #render :json=>json_out
        
        if !@project.project_profile.overview.blank? 
          if(@project.project_profile.overview.length > 400)
            overview = @project.project_profile.overview[0,399].html_safe + "..."
          else 
            overview = @project.project_profile.overview.html_safe
          end
        else
           overview = ''
        end
        
        adjacencies = []
        @project.people.each do |per|
          adjacencies << {:nodeTo => per.id.to_s }
        end
        #@person.organizations.each do |org|
        #  adjacencies << {:nodeTo => "o_" + org.id.to_s }
        #end
        
        json_out = []
        json_out << {:id=>"p_" + @project.id.to_s, :name=>@project.name, :data=>{"$color" => "#4B8A08", :controller=>'projects', :overview => overview}, :adjacencies=>adjacencies}
        

        @project.people.each do |per|
          json_out << {:id => per.id.to_s, :name=> per.full_name, :data=>{"$color" => "#415C7E", :parent=>@project.name, :relation=>"People", :controller=>'people'}}
        end
        #@person.organizations.each do |org|
        #  json_out << {:id => "o_" + org.id.to_s, :name=> org.name, :data=>{:parent=>@person.full_name, :relation=>"organization"}}
        #end
        render :json=>json_out
      end
    end
  end
  
  # GET /projects/new
  # GET /projects/new.xml
  def new
    @project = Project.new
    
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /projects/1/edit
  def edit
    @project = Project.find(params[:id])
    @allowed_to_edit = allowed_to_edit?(@project)
    @uses_text_editor = true
    @current_style = :details
    @selected_tab = determine_selected_tab(@project,false)    
    @tag_combiner = ProfileTagCombiner.new

    # prevent unauthorized access
    unless full_access_project_member?(@project) 
      redirect_to(@project) 
      return
    end  
  end
  
   # GET /projects/1/edit_picture
   def edit_picture
     @project = Project.find(params[:id])
     @allowed_to_edit = allowed_to_edit?(@project)

     # prevent unauthorized access
     unless full_access_project_member?(@project) 
       redirect_to(@project) 
       return
     end
   end

  # POST /projects
  # POST /projects.xml
  def create
    
    # prevent unauthorized access
    unless full_access?
      redirect_to(@project) 
      return
    end
      
    @project = Project.new(params[:project])
    @project.user = current_user
    @current_style = :details
  
    # use the uploaded image or a placeholder if there wasn't one
    if !params[:project][:uploaded_data].nil?
      @project.image = Image.new({ :uploaded_data => params[:project][:uploaded_data] })
      @project.image.save
    else
      #@project.image = Project.placeholder_image
    end
    
    # add the creator of the project to the project by default
    Relationship.add_person_to_project(current_user.person,@project)
    
    # add a blank project profile
    @project.create_project_profile()
    
    respond_to do |format|
      if @project.save
        flash[:notice] = 'Project was successfully created.'
        format.html { redirect_to(@project) }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  # GET /projects
  # GET /projects.xml
  def available_projects
    @tag_string = params[:tag_string]
    if !@tag_string.nil?
      @search_projects = get_by_solr_tag(@tag_string)
      # only accept valid sort param
      @sort_order = params[:sort] == "name" || params[:sort] == "updated_at" ? params[:sort] : "name"
      order_string = (@sort_order == "updated_at") ? "updated_at DESC" : @sort_order
      # condition is necessary to fix a rails model caching bug in production mode.
      @projects = Project.paginate :page => params[:page], :per_page => 20, :order => order_string, :conditions => {:id => @search_projects}
    else
      # only accept valid sort param
      @sort_order = params[:sort] == "name" || params[:sort] == "updated_at" ? params[:sort] : "name"
      order_string = (@sort_order == "updated_at") ? "updated_at DESC" : @sort_order
      # condition is necessary to fix a rails model caching bug in production mode.
      @projects = Project.paginate :page => params[:page], :per_page => 20, :order => order_string, :conditions => "type = 'Project'"
    end
    @profile_view = false    
    @current_style = :gallery

    #respond_to do |format|
    #  format.html # index.html.erb
    #  format.xml  { render :xml => @projects }
    #end
  end
  
  
  # GET /projects/1/find_member
  def find_member
    @project = Project.find(params[:id])
    unless admin?
      @people = Person.find(:all, :conditions => ["user_id not in (select id from users where access_level = ?) and user_id not in (select id from users where private_profile = ?)", "Pending", true]) - @project.people
    else
      @people = Person.find(:all, :conditions => ["user_id not in (select id from users where access_level = ?)", "Pending"]) - @project.people     
    end
    @current_style = :details
    
    # prevent unauthorized access
    unless full_access_project_member?(@project) 
     redirect_to(@project) 
     return
    end  
  end
  
  # GET /projects/1/invite_member
  def invite_member
    @project = Project.find(params[:id])
    @profile_view = false    
    @current_style = :details
    @tiny_mce_editor_disable = true

    # prevent unauthorized access
    unless full_access_project_member?(@project) 
     redirect_to(@project) 
     return
    end  
  end
  
  # POST /projects/1/create_member
  def create_member
      @project = Project.find(params[:id])           

      # prevent unauthorized access
      unless full_access_project_member?(@project) 
        redirect_to(@project) 
        return
      end
      
      # nothing selected
      if params['entity'].nil?        
        redirect_to(@project) 
        return
      end

      respond_to do |format|
          params['entity'].keys.each { |id| 
            person = Person.find(id.to_i)
            relation = Relationship.add_person_to_project(person,@project)
            relation.save!            
          } 

          if @project.save
            flash[:notice] = 'Members have been added.'
            format.html { redirect_to(@project) }
          else
            # TODO add flash message?
            format.html { render :action => "new" }
          end
      end
  end
  
  def join_project
    @project = Project.find(params[:id])           

     # prevent unauthorized access
     unless full_access? 
       redirect_to(@project) 
       return
     end

     respond_to do |format|
       unless current_user.person.projects.include?(@project)
         relation = Relationship.add_person_to_project(current_user.person,@project)
         relation.save!            

         if @project.save
           flash[:notice] = "You have joined #{@project.name}."
           format.html { redirect_to(@project) }
         else
           #TODO add flash message?
           format.html { render :action => "new" }
         end
        else
          flash[:notice] = "You are already a member of #{@project.name}."
          format.html { redirect_to(@project) }
        end
     end   
  end
  
  # POST /projects/1/create_member
  def create_member_email
    @project = Project.find(params[:id])           

    # prevent unauthorized access
    unless full_access_project_member?(@project) 
      redirect_to(@project) 
      return
    end
    
    respond_to do |format|
      if @project.update_attributes(params[:project])
        
        # for now, only add invitees who already have accounts
        @project.invitees.each do |invitee|         
          invited_user = User.find_by_email( invitee[:email] )
          unless invited_user.nil?
            relation = Relationship.add_person_to_project(invited_user.person,@project)
            relation.save!
          else        
            @project.invite_by_email( invitee, current_user )
          end
        end        
        
        if @project.save
          flash[:notice] = 'Team members have been added.'
          format.html { redirect_to(@project) }
        else
          # TODO add flash message?
          format.html { render :action => "new" }
        end
      else
        #TODO flash parse errors for invite list
        format.html { render :action => "new" }
      end
    end
  end
  
  # DELETE /projects/remove_member/1?entity=2
  def remove_member
    project = Project.find(params[:id])
    person = Person.find(params[:entity])

    # prevent unauthorized access  
    unless full_access_project_member?(project) || person.id == current_user.id
      redirect_to(project) 
      return
    end    
    
    Relationship.remove_person_from_project(person,project)

    respond_to do |format|
      format.html { 
        flash[:notice] = "#{person.name} is no longer a member of #{project.name}" 
        redirect_to(project) 
      }
    end      
  end
  
  # PUT /projects/1
  # PUT /projects/1.xml
  def update
    @project = Project.find(params[:id])
    
    # prevent unauthorized access
    unless full_access_project_member?(@project) 
      redirect_to(@project) 
      return
    end
    
    if params[:project][:uploaded_data] and params[:project][:uploaded_data] != ""
      @project.image = Image.new({ :uploaded_data => params[:project][:uploaded_data] })
      @project.image.save
      @project.save
    end
    
    respond_to do |format|
      if @project.update_attributes(params[:project])
        flash[:notice] = 'Project was successfully updated.'
        format.html { redirect_to(@project) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def update_profile
    @project = Project.find(params[:id])
    @current_style = :details    
    @selected_tab = determine_selected_tab(@project,false)    
    
    unless @project.project_profile
      @project.create_project_profile()
    end
    
    respond_to do |format|
      if @project.project_profile.update_attributes(params[:project_profile])
        
        # index the updated profile for searching
        @project.index()
        
        flash[:notice] = 'Project was successfully updated.'
        format.html { redirect_to(url_for( :action => 'show', :id => @project.id, :tab => @selected_tab)) }
      else
        format.html { render :action => "edit", :tab => @selected_tab }
      end
    end   
  end
  
  # DELETE /projects/1
  # DELETE /projects/1.xml
  def destroy
    @project = Project.find(params[:id])
    
    # prevent unauthorized access
    unless full_access_project_member?(@project) 
      redirect_to(@project) 
      return
    end
    
    @project.remove_from_index
    @project.destroy

    respond_to do |format|
      format.html { redirect_to(projects_url) }
    end
  end
  
  protected
  def main_nav
    if APPLICATION_DOMAIN != 'shanti.virginia.edu'
      @current_nav_item = :projects
    else
      @current_nav_item = :uva_profiles #:home
      #@current_nav_item = :projects
      @current_sub_nav_item = :projects
    end
    @login_enabled = true
    @nav_enabled = true
    @profile_view = true    
  end
  
  def determine_selected_tab( project, hiding_blanks=true )    
    # if the tab param was given, use that tab, otherwise start on profile
    selected_tab = params[:tab].to_s.blank? ? :profile : params[:tab].to_sym
    
    return selected_tab unless hiding_blanks
    
    # guard against selecting a tab that is blank and therefore not visible
    if project.project_profile.field_set_blank?(selected_tab)
      return :profile
    end
    
    selected_tab
  end
     
  def get_by_solr_tag( tag_string)
    @search_query = tag_string
    @solr = SolrSearch.new( SOLR_URL )
    
    @facet_fields = ['type_facet']
    ProfileTagCombiner::TAG_FIELDS.each do |tag|
      @facet_fields << "#{tag}_facet"
    end
    
    solr_params = {:facets=>{:fields=>@facet_fields, :mincount=>1}}
    
    solr_params[:filter_queries] = []
    solr_params[:filter_queries] = "+type_facet:\"Project\" +(docType:\"entity\" docType:\"external\")"
    
    begin
      @solr_result_set = @solr.search(@search_query, solr_params)
    rescue Exception => e 
     #ExceptionNotifier.deliver_exception_notification(e, self, request)
    end
    
    unless @solr_result_set.nil?
      @projects_by_tag = []
      @search_results = @solr_result_set.hits.map
      for search_result in @search_results        
        #@project = Project.find(search_result["id"])
        @projects_by_tag = @projects_by_tag << search_result["id"]
      end
    end
    return @projects_by_tag
  end   
      
end