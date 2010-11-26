class UsageScenariosController < ApplicationController
  #layout "main"
  before_filter :main_nav

  # GET /usage_scenarios
  # GET /usage_scenarios.xml
  def index
    @tool = Tool.find(params[:tool_id])   
    render_usage_scenarios
  end

  # GET /usage_scenarios/1
  # GET /usage_scenarios/1.xml
  def show
    @usage_scenario = UsageScenario.find(params[:id])
    @tool = Tool.find(params[:tool_id])    
    respond_to do |format|
       format.html {redirect_to tool_url(@tool)}
    end
  end

  # GET /usage_scenarios/new
  # GET /usage_scenarios/new.xml
  def new
    @tool = Tool.find(params[:tool_id])   
    @usage_scenario = @tool.usage_scenarios.new
    @authors = Person.find(:all, :order => 'name')
    @scenario_types = ScenarioType.find(:all, :order => 'title')
    respond_to do |format|
      if request.xhr?
        format.html {render :partial => 'new'}
      else
        format.html {redirect_to tool_url(@tool)}
      end
      format.xml  { render :xml => @usage_scenario }
    end
  end

  # GET /usage_scenarios/1/edit
  def edit
    @tool = Tool.find(params[:tool_id])    
    @usage_scenario = UsageScenario.find(params[:id])
    @authors = Person.find(:all, :order => 'name')   
    @scenario_types = ScenarioType.find(:all, :order => 'title') 
    respond_to do |format|
      if request.xhr?
        format.html {render :partial => 'edit'}
      else
        format.html {redirect_to tool_url(@tool)}
      end
      format.xml  { render :xml => @usage_scenario }
    end
  end

  # POST /usage_scenarios
  # POST /usage_scenarios.xml
  def create
    @tool = Tool.find(params[:tool_id])   
    if @tool.usage_scenarios.empty?
      params[:usage_scenario][:is_primary] = "true"
    end
    @usage_scenario = UsageScenario.new(params[:usage_scenario])

    respond_to do |format|
      if @usage_scenario.save
        if request.xhr?
  		    format.html do
  		      render :partial => 'usage_scenarios/index', :locals => {:tool => @tool, :usage_scenario => nil}
  		    end  
        end
        format.xml  { render :xml => @usage_scenario, :status => :created, :location => @usage_scenario }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @usage_scenario.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /usage_scenarios/1
  # PUT /usage_scenarios/1.xml
  def update
    params[:usage_scenario][:author_ids] ||= []
    @usage_scenario = UsageScenario.find(params[:id])
    @tool = Tool.find(params[:tool_id])   

    respond_to do |format|
      if @usage_scenario.update_attributes(params[:usage_scenario])      
        if request.xhr?
  		    format.html do
  		      render :partial => 'usage_scenarios/index', :locals => {:tool => @tool, :usage_scenario => nil}
  	      end
  	    else
  	      format.html do
  	        redirect_to tool_url(@tool)
  	      end
  	    end      
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @usage_scenario.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /usage_scenarios/1
  # DELETE /usage_scenarios/1.xml
  def destroy
    @usage_scenario = UsageScenario.find(params[:id])
    @tool = Tool.find(params[:tool_id]) 
    @usage_scenario.destroy

    respond_to do |format|
      #format.html { redirect_to(usage_scenarios_url) }
      format.html do
        if request.xhr?
 		      render :partial => 'usage_scenarios/index', :locals => {:tool => @tool, :usage_scenario => nil}	  
        else
 		      redirect_to tool_url(@tool)           
        end
      end      
      format.xml  { head :ok }
    end
  end
  
  def add_author
    @authors = Person.find(:all, :order => 'name')
    render :partial => 'authors_selector', :locals => {:selected => nil}
  end

  def contract
    tool = Tool.find(params[:tool_id])   
    d = UsageScenario.find(params[:id])
    render :partial => 'contracted', :locals => {:tool => tool, :d => d}
  end
  
  def expand
    @tool = Tool.find(params[:tool_id])   
    @d = UsageScenario.find(params[:id])
    #@usage_scenario =  UsageScenario.find(params[:id])
    render_usage_scenarios
  end
 
  def contract_show
    tool = Tool.find(params[:tool_id])   
    d = UsageScenario.find(params[:id])
    render :partial => 'show_contracted', :locals => {:tool => tool, :d => d}
  end
  
  def expand_show
    @tool = Tool.find(params[:tool_id])   
    @d = UsageScenario.find(params[:id])
    #@usage_scenario =  UsageScenario.find(params[:id])
    render_usage_scenarios_show
  end

  
  private
  
  def render_usage_scenarios
    #find a way to save selected expanded usage_scenario
    render :update do |page|
	    yield(page) if block_given?
	    page.replace_html 'usage_scenarios_div', :partial => 'usage_scenarios/index', :locals => { :tool => @tool, :usage_scenario => @d}
	  end
	end  

  def render_usage_scenarios_show
    #find a way to save selected expanded usage_scenario
    render :update do |page|
	    yield(page) if block_given?
	    page.replace_html 'usage_scenarios_div', :partial => 'usage_scenarios/show_usage_scenarios', :locals => { :tool => @tool, :usage_scenario => @d}
	  end
	end
	
  protected
  def main_nav
    @current_nav_item = :tools
    @login_enabled = true
    @nav_enabled = true
    @profile_view = true    
  end
  
end
