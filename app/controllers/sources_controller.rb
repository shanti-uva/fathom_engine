class SourcesController < ApplicationController
  #layout "main"
  before_filter :find_tool
  before_filter :main_nav
    
  # GET /sources
  # GET /sources.xml
  def index
    #@tool = Tool.find(params[:tool_id]) 
    if !params[:review_id].nil?
      @resource = Review.find(params[:review_id])
    else
      if !params[:usage_scenario_id].nil?
        @resource = UsageScenario.find(params[:usage_scenario_id])
      else
        @resource = @tool
      end
    end 
    render_sources
  end

  # GET /sources/1
  # GET /sources/1.xml
  def show
    redirect_to(@tool) 
    #@tool = Tool.find(params[:tool_id])    
    #respond_to do |format|
    #   format.html {redirect_to tool_url(@tool)}
    #end
    
  end

  # GET /sources/new
  # GET /sources/new.xml
  def new
    #@languages = Language.find(:all, :order => 'title')
    if !params[:review_id].nil?
      @review = Review.find(params[:review_id])
    end
    if !params[:usage_scenario_id].nil?
      @usage_scenario = UsageScenario.find(params[:usage_scenario_id])
    end
    #@source = Source.new(:creator => current_user)
    @source = Source.new
    
    respond_to do |format|
      if !params[:review_id].nil?
        @source.resource = @review
        format.html {render :partial => 'new', :locals => {:review => @review} if request.xhr?}
      else
        if !params[:usage_scenario_id].nil?
          @source.resource = @usage_scenario
          format.html {render :partial => 'new', :locals => {:usage_scenario => @usage_scenario} if request.xhr?}
        else
          @source.resource = @tool
          format.html {render :partial => 'new' if request.xhr?} # new.html.erb
        end
      end
      format.xml  { render :xml => @source }
    end
  end

  # GET /sources/1/edit
  def edit
    #@languages = Language.find(:all, :order => 'title')
    if !params[:review_id].nil?
      @review = Review.find(params[:review_id])
    end
    if !params[:usage_scenario_id].nil?
      @usage_scenario = UsageScenario.find(params[:usage_scenario_id])
    end    
    @source = Source.find(params[:id])
    respond_to do |format|
      if !params[:review_id].nil?
        #@source.resource = @review
        format.html {render :partial => 'edit', :locals => {:review => @review} if request.xhr?}
      else
        if !params[:usage_scenario_id].nil?
          #@source.resource = @usage_scenario
          format.html {render :partial => 'edit', :locals => {:usage_scenario => @usage_scenario} if request.xhr?}
        else
          #@source.resource = @tool
          format.html {render :partial => 'edit' if request.xhr?} # new.html.erb
        end
      end
    end
  end

  # POST /sources
  # POST /sources.xml
  def create
    #@languages = Language.find(:all, :order => 'title')
    if !params[:review_id].nil?
      @review = Review.find(params[:review_id])
    end
    if !params[:usage_scenario_id].nil?
      @usage_scenario = UsageScenario.find(params[:usage_scenario_id])
    end
    @source = Source.new(params[:source])
    if !params[:review_id].nil?
      @source.resource = @review    
    else
      if !params[:usage_scenario_id].nil?
        @source.resource = @usage_scenario
      else
        @source.resource = @tool
      end
    end  
    respond_to do |format|
      if @source.save
        if request.xhr?
	        format.html do
            render :partial => 'sources/index', :locals => {:resource => @source.resource}   	  		
		      end
		    end          
      else
        format.html do
           #if request.xhr?
             if !params[:review_id].nil?
               @source.resource = @review
               render :partial => 'new', :locals => {:review => @review}
             else
               if !params[:usage_scenario_id].nil?
                 @source.resource = @usage_scenario
                 render :partial => 'new', :locals => {:usage_scenario => @usage_scenario}
               else
                 @source.resource = @tool
                 render :partial => 'new' # new.html.erb
               end
             end
           #else
            # debugger
            # render :action => 'new'
           #end
         end        
         format.xml  { render :xml => @source.errors, :status => :unprocessable_entity }                
      end
    end    
    
  end

  # PUT /sources/1
  # PUT /sources/1.xml
  def update
    @source = Source.find(params[:id])
    #@languages = Language.find(:all, :order => 'title')
    if !params[:review_id].nil?
      @review = Review.find(params[:review_id])
    end
    if !params[:usage_scenario_id].nil?
      @usage_scenario = UsageScenario.find(params[:usage_scenario_id])
    end
    if !params[:review_id].nil?
      @source.resource = @review    
    else
      if !params[:usage_scenario_id].nil?
        @source.resource = @usage_scenario
      else
        @source.resource = @tool
      end
    end
    respond_to do |format|
      if @source.update_attributes(params[:source])
        #flash[:notice] = 'Source was successfully updated.'
        #format.html { redirect_to(@source) }
        if request.xhr?
  		    format.html do
  		      render :partial => 'sources/index', :locals => {:resource => @source.resource}
  	      end
  	    else
  	      format.html do
  	        redirect_to tool_url(@tool)
  	      end
  	    end
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @source.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /sources/1
  # DELETE /sources/1.xml
  def destroy
    @source = Source.find(params[:id])
    #@tool = Tool.find(params[:tool_id])   
    if !params[:review_id].nil?
      current_resource = Review.find(@source.resource_id)    
    else
      if !params[:usage_scenario_id].nil?
        current_resource = UsageScenario.find(@source.resource_id)
      else
        current_resource = @tool
      end
    end
    @source.destroy


    respond_to do |format|
      format.html do
        if request.xhr?
 		      render :partial => 'sources/index', :locals => {:resource => current_resource}	  
        else
 		      redirect_to tool_url(@tool)           
        end
      end
      format.xml  { head :ok }
    end
  end
  
  def contract
    @source =  nil
    s = Source.find(params[:id])
    if !params[:review_id].nil?
      resource = Review.find(params[:review_id])
    else  
      if !params[:usage_scenario_id].nil?
        resource = UsageScenario.find(params[:usage_scenario_id])
      else
        resource = @tool
      end
    end
    render :partial => 'contracted', :locals => {:resource => resource, :s => s}
   end
   
   def expand
     @source = Source.find(params[:id])
     if @source.resource_type == 'Review'
       @resource = Review.find(@source.resource_id)
     else 
       if @source.resource_type == 'UsageScenario'
         @resource = UsageScenario.find(@source.resource_id)
       else
         @resource = @tool
       end
     end
     render_sources
   end

   def contract_show
     s = Source.find(params[:id])
     if !params[:review_id].nil?
       resource = Review.find(params[:review_id])
     else  
       if !params[:usage_scenario_id].nil?
         resource = UsageScenario.find(params[:usage_scenario_id])
       else
         resource = @tool
       end
     end     
     render :partial => 'show_contracted', :locals => {:resource => resource, :s => s}
   end

   def expand_show
     @source = Source.find(params[:id])
     if @source.resource_type == 'Review'
       @resource = Review.find(@source.resource_id)
     else 
       if @source.resource_type == 'UsageScenario'
         @resource = UsageScenario.find(@source.resource_id)
       else
         @resource = @tool
       end
     end
     render_sources_show
   end   
   
   private
   # This is tied to tools
   def find_tool
     @tool = Tool.find(params[:tool_id])
   end

   def render_sources
     render :update do |page|
 	    yield(page) if block_given?
 	    if !params[:review_id].nil?
 	      page.replace_html 'reviewsources_div', :partial => 'sources/index', :locals => { :resource => @resource}
      else
        if !params[:usage_scenario_id].nil?
          page.replace_html 'usagescenariosources_div', :partial => 'sources/index', :locals => { :resource => @resource}
        else
          page.replace_html 'toolsources_div', :partial => 'sources/index', :locals => { :resource => @resource}
        end
      end
 	  end
   end
   
   def render_sources_show
     render :update do |page|
 	    yield(page) if block_given?
 	    if !params[:review_id].nil?
 	      page.replace_html 'reviewsources_div', :partial => 'sources/show_sources', :locals => { :resource => @resource}
      else
        if !params[:usage_scenario_id].nil?
          page.replace_html 'usagescenariosources_div', :partial => 'sources/show_sources', :locals => { :resource => @resource}
        else
          page.replace_html 'toolsources_div', :partial => 'sources/show_sources', :locals => { :resource => @resource}
        end
      end
 	  end
   end
   
   protected
   def main_nav
     @current_nav_item = :sources
     @login_enabled = true
     @nav_enabled = true
     @profile_view = true        
   end 
end
