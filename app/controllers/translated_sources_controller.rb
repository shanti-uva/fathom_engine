class TranslatedSourcesController < ApplicationController
  #layout "main"
  before_filter :find_tool, :find_source

  # GET /translated_sources
  # GET /translated_sources.xml
  def index
    @translated_sources = @source.translated_sources
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @translated_sources }
    end
  end

  # GET /translated_sources/1
  # GET /translated_sources/1.xml
  def show
    @translated_source = TranslatedSource.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @translated_source }
    end
  end

  # GET /translated_sources/new
  # GET /translated_sources/new.xml
  def new
    
    ##@source = Source.find(params[:source_id])
    @translated_source = TranslatedSource.new(:language => Language.find_by_code('bod'))
    @languages = Language.find(:all, :order => 'title')
    @authors = Person.find(:all, :order => 'name')
    #respond_to do |format|
    #  format.html {render :partial => 'new' if request.xhr?} # new.html.erb
    #  format.xml  { render :xml => @translated_source }
    #end    
  end

  # GET /translated_sources/1/edit
  def edit
  
    @translated_source = TranslatedSource.find(params[:id])
    @authors = Person.find(:all, :order => 'name')    
    #render :partial => 'edit' if request.xhr?
  end

  # POST /translated_sources
  # POST /translated_sources.xml
  def create
  
    @translated_source = TranslatedSource.new(params[:translated_source])
    ##source = Source.find(params[:source_id])
    ##@translated_source = @source.translated_sources.new(params[:translated_source])
    @translated_source.source = @source
    @translated_source.creator = current_user
    #respond_to do |format|
      if @translated_source.save
    #    if request.xhr?
	  #      format.html do
		#        render :partial => 'sources/index', :locals => {:resource => @source.resource}      	  		
		#      end	  	
    #    end
		#    format.xml  { render :xml => @translated_source, :status => :created, :location => @translated_source }		
    #  else    
    #    @languages = Language.find(:all, :order => 'title')
    #    @authors = Person.find(:all, :order => 'name')                
    #    format.html do
    #      if request.xhr?
    #        render :partial => 'new'
    #      else
    #        render :action => 'new'
    #      end
    #    end
    #    format.xml  { render :xml => @translated_source.errors, :status => :unprocessable_entity }
      end
    #end    
  end

  # PUT /translated_sources/1
  # PUT /translated_sources/1.xml
  def update
    
    params[:translated_source][:author_ids] ||= []
    @translated_source = TranslatedSource.find(params[:id])
    @authors = Person.find(:all, :order => 'name')    
	  #respond_to do |format|	
      if @translated_source.update_attributes(params[:translated_source])
	  #    if request.xhr?
		#      format.html do
		#        render :partial => 'sources/index', :locals => {:resource => @source.resource}   
	  #      end
		#      format.xml  { head :ok }  	
  	#    else
	  #      format.html do
		#        redirect_to tool_url(@tool) 
		#      end
		#      format.xml  { head :ok }      	  	
    #    end
    #  else	
    #    format.html do
    #      if request.xhr?
    #        render :partial => 'edit'
    #      else
    #        render :action => 'edit'
    #      end
    #    end
    #    format.xml  { render :xml => @translated_source.errors, :status => :unprocessable_entity }
      end
    #end
  end

  # DELETE /translated_sources/1
  # DELETE /translated_sources/1.xml
  def destroy
    @translated_source = TranslatedSource.find(params[:id])
    @translated_source.destroy
    #respond_to do |format|
    #  format.html do
    #    if request.xhr?
		#      render :partial => 'sources/index', :locals => {:resource => @source.resource}	  
    #    else
		#      redirect_to tool_url(@tool)
    #    end
    #  end
    #  format.xml  { head :ok }
    #end
  end
  
  def add_author
    @authors = Person.find(:all, :order => 'name')
    #render :partial => 'authors_selector', :locals => {:selected => nil}
  end
  
  private
  # This is tied to categories, but once other titles are translated it can get disentangled through request.request_uri
  def find_tool
    @tool = Tool.find(params[:tool_id])
  end
  
  def find_source
    @source = Source.find(params[:source_id])
  end
  
end
