class OrganizationsController < ApplicationController
  
  #layout "main"
  before_filter :login_required, :except => [ :index, :show ]
  before_filter :main_nav
  
  # GET /organizations
  # GET /organizations.xml
  def index
    # only accept valid sort param
    @sort_order = params[:sort] == "name" || params[:sort] == "updated_at" ? params[:sort] : "name"
    order_string = (@sort_order == "updated_at") ? "updated_at DESC" : @sort_order
    @organizations = Organization.paginate :page => params[:page], :per_page => 20, :order => order_string
    @current_style = :gallery

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @organizations }
    end
  end

  # GET /organizations/1
  # GET /organizations/1.xml
  def show
    @organization = Organization.find(params[:id])
    session[:start_node_id] = @organization.node_id
    @current_style = :showview #@current_style = :details
    @selected_tab = determine_selected_tab(@organization,false)        
    @tag_combiner = ProfileTagCombiner.new
  
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @organization }
      format.json do
        # create hash that includes the "thumb" method output
        json_out={:thumb=>@organization.thumb_src, :image=>@organization.image_src}
        # popuplate hash with all column values
        Organization.columns.each{|c|json_out[c.name]=@organization.send(c.name)}
        # render json
        render :json=>json_out
      end
    end
  end

  # GET /organizations/new
  # GET /organizations/new.xml
  def new
    @organization = Organization.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @organization }
    end
  end
 
  # GET /organizations/1/find_member
  def find_member   
    @organization = Organization.find(params[:id])
    @people = Person.find(:all) - @organization.people
    @current_style = :details
    
    # prevent unauthorized access
    unless full_access_organization_member?(@organization) 
      redirect_to(@organization)
      return
    end  
  end
  
  # GET /organizations/1/invite_member
  def invite_member
    @organization = Organization.find(params[:id])
    @current_style = :details
    @tiny_mce_editor_disable = true
    
    # prevent unauthorized access
    unless full_access_organization_member?(@organization) 
      redirect_to(@organization)
      return
    end  
  end
   
  # GET /organizations/new_subproject/1
  def new_subproject
    @organization = Organization.find(params[:id])  
    @current_style = :details

    # prevent unauthorized access
    unless full_access_organization_member?(@organization) 
      redirect_to(@organization) 
      return
    end
      
    # display only projects which are not already part of this organization
    @projects = Project.find(:all) - (@organization.projects + [@organization])
    # Project.find(:all) returns Organizations too!? Manually filter them out... 
    @projects.delete_if{|p|p.class==Organization}
  end
  
  # DELETE /organizations/remove_subproject/1?entity=2
  def remove_subproject
    organization = Organization.find(params[:id])
    project = Project.find(params[:entity])

    # prevent unauthorized access
    unless full_access_organization_member?(organization) 
      redirect_to(organization) 
      return
    end    
    
    Relationship.remove_project_from_organization(project,organization)

    respond_to do |format|
      format.html { 
        flash[:notice] = "#{project.name} is no longer a subproject of #{organization.name}" 
        redirect_to(organization) 
      }
    end      
  end

  # DELETE /organizations/remove_member/1?entity=2
  def remove_member
    organization = Organization.find(params[:id])
    person = Person.find(params[:entity])

    # prevent unauthorized access
    unless full_access_organization_member?(organization) || person.id == current_user.id
      redirect_to(organization) 
      return
    end    
    
    Relationship.remove_person_from_organization(person,organization)

    respond_to do |format|
      format.html { 
        flash[:notice] = "#{person.name} is no longer a member of #{organization.name}" 
        redirect_to(organization) 
      }
    end      
  end
  
  # POST /organizations/1/create_member
  def create_member
    @organization = Organization.find(params[:id])           

    # prevent unauthorized access
    unless full_access_organization_member?(@organization) 
      redirect_to(@organization) 
      return
    end

    respond_to do |format|
      unless params['entity'].nil?
        params['entity'].keys.each { |id|
          person = Person.find(id.to_i)
          relation = Relationship.add_person_to_organization(person,@organization)
          relation.save!
        }
      end

      if @organization.save
        flash[:notice] = 'Members have been added.'
        format.html { redirect_to(@organization) }
      else
        # TODO add flash message?
        format.html { render :action => "new" }
      end
    end
  end
  
  def join_organization
    @organization = Organization.find(params[:id])           

    # prevent unauthorized access
    unless full_access?
      redirect_to(@organization)
      return
    end

    respond_to do |format|
      unless current_user.person.organizations.include?(@organization)
        person = current_user.person
        relation = Relationship.add_person_to_organization(person,@organization)
        relation.save!

        if @organization.save
          flash[:notice] = 'Members have been added.'
          format.html { redirect_to(@organization) }
        else
          #TODO add flash message?
          format.html { render :action => "new" }
        end
      else
        flash[:notice] = "You are already a member of #{@organization.name}."
        format.html { redirect_to(@organization) }
      end
    end
  end

  # POST /organizations/1/create_subproject
  def create_subproject
    @organization = Organization.find(params[:id])

    # prevent unauthorized access
    unless full_access_organization_member?(@organization)
      redirect_to(@organization)
      return
    end

    # nothing selected
    if params['entity'].nil?
      redirect_to(@organization)
      return
    end

    respond_to do |format|
      params['entity'].keys.each { |id|
        project = Project.find(id.to_i)
        relation = Relationship.add_project_to_organization(project,@organization)
        relation.save!
      }

      if @organization.save
        project_count = params['entity'].keys.size
        plural = (project_count > 1)
        flash[:notice] = "#{project_count} subproject#{plural ? 's' : ''} #{plural ? 'have' : 'has'} been added to #{@organization.name}"
        format.html { redirect_to(@organization) }
      else
        # TODO add flash message?
        format.html { render :action => "show" }
      end
    end
  end
   

  # POST /organizations/1/create_member
  def create_member_email
    @organization = Organization.find(params[:id])

    # prevent unauthorized access
    unless full_access_organization_member?(@organization)
      redirect_to(@organization)
      return
    end

    respond_to do |format|
      if @organization.update_attributes(params[:organization])

        # for now, only add invitees who already have accounts
        @organization.invitees.each do |invitee|
          invited_user = User.find_by_email( invitee[:email] )
          unless invited_user.nil?
            relation = Relationship.add_person_to_organization(invited_user.person,@organization)
            relation.save!
          end
          #TODO invite new users w/e-mail etc
        end

        if @organization.save
          flash[:notice] = 'Organization members have been added.'
          format.html { redirect_to(@organization) }
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

  # GET /organizations/1/edit
  def edit
    @organization = Organization.find(params[:id])
    @uses_text_editor = true
    @current_style = :details
    @selected_tab = determine_selected_tab(@organization,false)      
    @allowed_to_edit = allowed_to_edit?(@organization)
    @tag_combiner = ProfileTagCombiner.new

    # prevent unauthorized access
    unless full_access_organization_member?(@organization) 
      redirect_to(@organization) 
      return
    end    
  end
  
  # GET /projects/1/edit_picture
  def edit_picture
    @organization = Organization.find(params[:id])
    @allowed_to_edit = allowed_to_edit?(@organization)

    # prevent unauthorized access
    unless full_access_organization_member?(@organization)
      redirect_to(@organization)
      return
    end
  end

  # POST /organizations
  # POST /organizations.xml
  def create

    unless full_access? 
      redirect_to(@organization) 
      return
    end

    @organization = Organization.new(params[:organization])
    @organization.user = current_user
  
    # use the uploaded image or a placeholder if there wasn't one
    if !params[:organization][:uploaded_data].nil?
      @organization.image = Image.new({ :uploaded_data => params[:organization][:uploaded_data] })
      @organization.image.save
    end
      
    # add the creator of the organization to the organization by default
    Relationship.add_person_to_organization(current_user.person,@organization)  
    
    # add a blank project profile
    @organization.create_project_profile()
  
    respond_to do |format|
      if @organization.save
        flash[:notice] = 'Organization was successfully created.'
        format.html { redirect_to(@organization) }
        format.xml  { render :xml => @organization, :status => :created, :location => @organization }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @organization.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /organizations/1
  # PUT /organizations/1.xml
  def update
    @organization = Organization.find(params[:id])

    # prevent unauthorized access
    unless full_access_organization_member?(@organization) 
      redirect_to(@organization) 
      return
    end    
    
    if params[:organization][:uploaded_data] and params[:organization][:uploaded_data] != ""
      @organization.image = Image.new({ :uploaded_data => params[:organization][:uploaded_data] })
      @organization.image.save
      @organization.save
    end
    
    respond_to do |format|
      if @organization.update_attributes(params[:organization])
        flash[:notice] = 'Organization was successfully updated.'
        format.html { redirect_to(@organization) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @organization.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update_profile
    @organization = Organization.find(params[:id])
    @current_style = :details    
    @selected_tab = determine_selected_tab(@organization,false)      
    
    unless @organization.project_profile
      @organization.create_project_profile()
    end
        
    respond_to do |format|
      if @organization.project_profile.update_attributes(params[:project_profile])
        
        # index the updated profile for searching
        @organization.index()
        
        flash[:notice] = 'Organization was successfully updated.'
        format.html { redirect_to(url_for( :action => 'show', :id => @organization.id, :tab => @selected_tab)) }
      else
        format.html { render :action => "edit", :tab => @selected_tab }
      end
    end   
  end
  
  # DELETE /organizations/1
  # DELETE /organizations/1.xml
  def destroy
    @organization = Organization.find(params[:id])

    # prevent unauthorized access
    unless full_access_organization_member?(@organization) 
      redirect_to(@organization) 
      return
    end    

    @organization.remove_from_index()
    @organization.destroy

    respond_to do |format|
      format.html { redirect_to(organizations_url) }
    end
  end
  
  protected
  def main_nav
    if APPLICATION_DOMAIN != 'shanti.virginia.edu'
      @current_nav_item = :organizations
    else
      @current_nav_item = :uva_profiles #:home
      #@current_nav_item = :organizations
      @current_sub_nav_item = :organizations
    end
    @login_enabled = true
    @nav_enabled = true
    @profile_view = true        
  end
  
  def determine_selected_tab( organization, hiding_blanks=true )    
    # if the tab param was given, use that tab, otherwise start on profile
    selected_tab = params[:tab].to_s.blank? ? :profile : params[:tab].to_sym
    
    return selected_tab unless hiding_blanks
    
    # guard against selecting a tab that is blank and therefore not visible
    if organization.project_profile.field_set_blank?(selected_tab)
      return :profile
    end
    
    selected_tab
  end
    
end
