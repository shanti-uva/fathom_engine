class BlacklistsController < ApplicationController
  #layout "main"
  
  before_filter :login_required, :only => [ :index, :update ]
  before_filter :main_nav
  
  # GET /blacklists
  # GET /blacklists.xml
  def index
    unless admin?
      render :nothing => true
      return
    end
    @blacklists = Blacklist.all
    @current_style = :gallery
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @blacklists }
    end
    #render :action => 'index', :layout => 'main'
  end

  # GET /blacklists/1
  # GET /blacklists/1.xml
  def show
    unless admin?
      render :nothing => true
      return
    end
    @blacklist = Blacklist.find(params[:id])
    @current_style = :gallery
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @blacklist }
    end
  end

  # GET /blacklists/new
  # GET /blacklists/new.xml
  def new
    @blacklist = Blacklist.new
    @current_style = :gallery
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @blacklist }
    end
  end

  # GET /blacklists/1/edit
  def edit
    unless admin?
      render :nothing => true
      return
    end
    @blacklist = Blacklist.find(params[:id])
    @current_style = :gallery
  end

  # POST /blacklists
  # POST /blacklists.xml
  def create
    @blacklist = Blacklist.new(params[:blacklist])

    respond_to do |format|
      if @blacklist.save
        flash[:notice] = 'Blacklist was successfully created.'
        format.html { redirect_to(@blacklist) }
        format.xml  { render :xml => @blacklist, :status => :created, :location => @blacklist }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @blacklist.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /blacklists/1
  # PUT /blacklists/1.xml
  def update
    @blacklist = Blacklist.find(params[:id])

    respond_to do |format|
      if @blacklist.update_attributes(params[:blacklist])
        flash[:notice] = 'Blacklist was successfully updated.'
        format.html { redirect_to(@blacklist) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @blacklist.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /blacklists/1
  # DELETE /blacklists/1.xml
  def destroy
    @blacklist = Blacklist.find(params[:id])
    @blacklist.destroy

    respond_to do |format|
      format.html { redirect_to(blacklists_url) }
      format.xml  { head :ok }
    end
  end
  
  
  protected
  def main_nav
    @current_nav_item = :blacklists
    @login_enabled = true
    @nav_enabled = true
    @profile_view = true        
  end  
end
