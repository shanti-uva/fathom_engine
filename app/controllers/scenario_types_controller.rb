class ScenarioTypesController < ApplicationController
  # GET /scenario_types
  # GET /scenario_types.xml
  def index
    @scenario_types = ScenarioType.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @scenario_types }
    end
  end

  # GET /scenario_types/1
  # GET /scenario_types/1.xml
  def show
    @scenario_type = ScenarioType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @scenario_type }
    end
  end

  # GET /scenario_types/new
  # GET /scenario_types/new.xml
  def new
    @scenario_type = ScenarioType.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @scenario_type }
    end
  end

  # GET /scenario_types/1/edit
  def edit
    @scenario_type = ScenarioType.find(params[:id])
  end

  # POST /scenario_types
  # POST /scenario_types.xml
  def create
    @scenario_type = ScenarioType.new(params[:scenario_type])

    respond_to do |format|
      if @scenario_type.save
        flash[:notice] = 'ScenarioType was successfully created.'
        format.html { redirect_to(@scenario_type) }
        format.xml  { render :xml => @scenario_type, :status => :created, :location => @scenario_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @scenario_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /scenario_types/1
  # PUT /scenario_types/1.xml
  def update
    @scenario_type = ScenarioType.find(params[:id])

    respond_to do |format|
      if @scenario_type.update_attributes(params[:scenario_type])
        flash[:notice] = 'ScenarioType was successfully updated.'
        format.html { redirect_to(@scenario_type) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @scenario_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /scenario_types/1
  # DELETE /scenario_types/1.xml
  def destroy
    @scenario_type = ScenarioType.find(params[:id])
    @scenario_type.destroy

    respond_to do |format|
      format.html { redirect_to(scenario_types_url) }
      format.xml  { head :ok }
    end
  end
end
