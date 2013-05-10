class ToolsController < ApplicationController
  #layout "main"
  before_filter :login_required, :except => [ :index, :show ]
  before_filter :main_nav
  
  # GET /tools
  # GET /tools.xml
  def index
    # only accept valid sort param
    @sort_order = params[:sort] == "name" || params[:sort] == "updated_at" ? params[:sort] : "name"
    order_string = (@sort_order == "updated_at") ? "updated_at DESC" : @sort_order
    # condition is necessary to fix a rails model caching bug in production mode.
    @tools = Tool.paginate :page => params[:page], :per_page => 20, :order => order_string, :conditions => "type = 'Tool'"
    @profile_view = false    
    @current_style = :gallery

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tools }
    end
  end

  # GET /tools/1
  # GET /tools/1.xml
  def show
    @tool = Tool.find(params[:id])
    session[:start_node_id] = @tool.node_id
    session[:hypertree_start_node_id] = 'tools/' + @tool.id.to_s + '.json' 
    @current_style = :showview #@current_style = :details
    @selected_tab = determine_selected_tab(@tool)    
    @tag_combiner = ProfileTagCombiner.new

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tool }
      format.json do
        # create hash that includes the "thumb" method output
        json_out={:thumb=>@tool.thumb_src, :image=>@tool.image_src}
        # populate hash with all column values
        Tool.columns.each{|c|json_out[c.name]=@tool.send(c.name)}
        # render json
        render :json=>json_out
      end
    end
  end

  # GET /tools/new
  # GET /tools/new.xml
  def new
    @tool = Tool.new
    
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /tools/1/edit
  def edit
    @tool = Tool.find(params[:id])
    @allowed_to_edit = allowed_to_edit?(@tool)
    @uses_text_editor = true
    @current_style = :details
    @selected_tab = determine_selected_tab(@tool,false)    
    @tool_type = Category.find(4235) # Digital Tools & Approaches id in topical map builder
    @tool_profile = @tool.tool_profile
    @tag_combiner = ProfileTagCombiner.new
    
    # prevent unauthorized access
    unless full_access? #full_access_tool_member?(@tool) 
      redirect_to(@tool) 
      return
    end  
  end

  def dialog
    @current_style = :details
    render :layout => 'test_dialog'
  end
  
   # GET /tools/1/edit_picture
   def edit_picture
     @tool = Tool.find(params[:id])
     @allowed_to_edit = allowed_to_edit?(@tool)

     # prevent unauthorized access
     unless full_access? #full_access_tool_member?(@tool) 
       redirect_to(@tool) 
       return
     end
   end

  # POST /tools
  # POST /tools.xml
  def create
    # prevent unauthorized access
    unless full_access?
      redirect_to(@tool) 
      return
    end
      
    @tool = Tool.new(params[:tool])
    @tool.user = current_user
    @current_style = :details
  
    # use the uploaded image or a placeholder if there wasn't one
    if !params[:tool][:uploaded_data].nil?
      @tool.image = Image.new({ :uploaded_data => params[:tool][:uploaded_data] })
      @tool.image.save
    end
    
    # add the creator of the tool to the tool by default
    Relationship.add_person_to_tool(current_user.person,@tool)
    
    # add a blank tool profile
    @tool.create_tool_profile()
    
    respond_to do |format|
      if @tool.save
        flash[:notice] = 'Tool was successfully created.'
        format.html { redirect_to(@tool) }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  # GET /tools/1/find_member
  def find_member
    @tool = Tool.find(params[:id])
    unless admin?
      @people = Person.find(:all, :conditions => ["user_id not in (select id from users where access_level = ?) and user_id not in (select id from users where private_profile = ?)", "Pending", true]) - @tool.people
    else
      @people = Person.find(:all, :conditions => ["user_id not in (select id from users where access_level = ?)", "Pending"]) - @tool.people     
    end
    @current_style = :details
    
    # prevent unauthorized access
    unless full_access_tool_member?(@tool) 
     redirect_to(@tool) 
     return
    end  
  end
  
  # GET /tools/1/invite_member
  def invite_member
    @tool = Tool.find(params[:id])
    @profile_view = false    
    @current_style = :details
    #@tiny_mce_editor_disable = true

    # prevent unauthorized access
    unless full_access_tool_member?(@tool) 
     redirect_to(@tool) 
     return
    end  
  end
  
  # POST /tools/1/create_member
  def create_member
      @tool = Tool.find(params[:id])           

      # prevent unauthorized access
      unless full_access_tool_member?(@tool) 
        redirect_to(@tool) 
        return
      end
      
      # nothing selected
      if params['entity'].nil?        
        redirect_to(@tool) 
        return
      end

      respond_to do |format|
          params['entity'].keys.each { |id| 
            person = Person.find(id.to_i)
            relation = Relationship.add_person_to_tool(person,@tool)
            relation.save!            
          } 

          if @tool.save
            flash[:notice] = 'Members have been added.'
            format.html { redirect_to(@tool) }
          else
            # TODO add flash message?
            format.html { render :action => "new" }
          end
      end
  end
  
  def join_tool
    @tool = Tool.find(params[:id])           

     # prevent unauthorized access
     unless full_access? 
       redirect_to(@tool) 
       return
     end

     respond_to do |format|
       unless current_user.person.tools.include?(@tool)
         relation = Relationship.add_person_to_tool(current_user.person,@tool)
         relation.save!            

         if @tool.save
           flash[:notice] = "You are related to #{@tool.name}."
           format.html { redirect_to(@tool) }
         else
           #TODO add flash message?
           format.html { render :action => "new" }
         end
        else
          flash[:notice] = "You are already a member of #{@tool.name}."
          format.html { redirect_to(@tool) }
        end
     end   
  end
  
  # POST /tools/1/create_member
  def create_member_email
    @tool = Tool.find(params[:id])           

    # prevent unauthorized access
    unless full_access_tool_member?(@tool) 
      redirect_to(@tool) 
      return
    end
    
    respond_to do |format|
      if @tool.update_attributes(params[:tool])
        
        # for now, only add invitees who already have accounts
        @tool.invitees.each do |invitee|         
          invited_user = User.find_by_email( invitee[:email] )
          unless invited_user.nil?
            relation = Relationship.add_person_to_tool(invited_user.person,@tool)
            relation.save!
          else        
            @tool.invite_by_email( invitee, current_user )
          end
        end        
        
        if @tool.save
          flash[:notice] = 'Team members have been added.'
          format.html { redirect_to(@tool) }
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
  
  # DELETE /tools/remove_member/1?entity=2
  def remove_member
    tool = Tool.find(params[:id])
    person = Person.find(params[:entity])

    # prevent unauthorized access  
    unless full_access_tool_member?(tool) || person.id == current_user.id
      redirect_to(tool) 
      return
    end    
    
    Relationship.remove_person_from_tool(person,tool)

    respond_to do |format|
      format.html { 
        flash[:notice] = "#{person.name} is no longer a member of #{tool.name}" 
        redirect_to(tool) 
      }
    end
  end

  # PUT /tools/1
  # PUT /tools/1.xml
  def update
    @tool = Tool.find(params[:id])
    
    # prevent unauthorized access
    unless full_access_tool_member?(@tool) 
      redirect_to(@tool) 
      return
    end
    
    if params[:tool][:uploaded_data] and params[:tool][:uploaded_data] != ""
      @tool.image = Image.new({ :uploaded_data => params[:tool][:uploaded_data] })
      @tool.image.save
      @tool.save
    end
    
    respond_to do |format|
      if @tool.update_attributes(params[:tool])
        flash[:notice] = 'Tool was successfully updated.'
        format.html { redirect_to(@tool) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def update_profile
    
    @tool = Tool.find(params[:id])
    @current_style = :details    
    @selected_tab = determine_selected_tab(@tool,false)    
    
    unless @tool.tool_profile
      @tool.create_tool_profile()
    end
    
    
    respond_to do |format|
      if @tool.tool_profile.update_attributes(params[:tool_profile])
        
        # index the updated profile for searching
        @tool.index()
        
        flash[:notice] = 'Tool was successfully updated.'
        format.html { redirect_to(url_for( :action => 'show', :id => @tool.id, :tab => @selected_tab)) }
      else
        format.html { render :action => "edit", :tab => @selected_tab }
      end
    end   
  end
  # DELETE /tools/1
  # DELETE /tools/1.xml
  def destroy
    @tool = Tool.find(params[:id])
    
    # prevent unauthorized access
    unless full_access_tool_member?(@tool) 
      redirect_to(@tool) 
      return
    end
    
    @tool.remove_from_index
    @tool.destroy

    respond_to do |format|
      format.html { redirect_to(tools_url) }
    end
  end
  

  protected
  def main_nav
    if APPLICATION_DOMAIN != 'shanti.virginia.edu'
      @current_nav_item = :tools
    else
      @current_nav_item = :uva_profiles #:home
      #@current_nav_item = :tools
      @current_sub_nav_item = :tools
    end
    @login_enabled = true
    @nav_enabled = true
    @profile_view = true    
  end
  def determine_selected_tab( tool, hiding_blanks=true )    
    # if the tab param was given, use that tab, otherwise start on profile
    selected_tab = params[:tab].to_s.blank? ? :profile : params[:tab].to_sym
    
    return selected_tab unless hiding_blanks
    
    # guard against selecting a tab that is blank and therefore not visible
    if tool.tool_profile.field_set_blank?(selected_tab)
      return :profile
    end
    
    selected_tab
  end
end
