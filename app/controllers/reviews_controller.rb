class ReviewsController < ApplicationController
  #layout "main"
  before_filter :main_nav
  								  
  # GET /reviews
  # GET /reviews.xml
  def index
   @tool = Tool.find(params[:tool_id])   
   render_reviews
  end

  # GET /reviews/1
  # GET /reviews/1.xml
  def show
    @review = Review.find(params[:id])
    @tool = Tool.find(params[:tool_id])    
    respond_to do |format|
       format.html {redirect_to tool_url(@tool)}
    end
  end

  # GET /reviews/new
  # GET /reviews/new.xml
  def new 
    @tool = Tool.find(params[:tool_id])   
    @review = @tool.reviews.new
    @authors = Person.find(:all, :order => 'name')
    #respond_to do |format|
    #  if request.xhr?
    #    format.html {render :partial => 'new'}
    #  else
    #    format.html {redirect_to tool_url(@tool)}
    #  end
    #  format.xml  { render :xml => @review }
    #end    
  end

  # GET /reviews/1/edit
  def edit
    @tool = Tool.find(params[:tool_id])    
    @review = Review.find(params[:id])
    @authors = Person.find(:all, :order => 'name')    
    #respond_to do |format|
    #  if request.xhr?
    #    format.html {render :partial => 'edit'}
    #  else
    #    format.html {redirect_to tool_url(@tool)}
    #  end
    #  format.xml  { render :xml => @review }
    #end   
  end

  # POST /reviews
  # POST /reviews.xml
  def create
    @tool = Tool.find(params[:tool_id])   
    #params[:review][:tool_id] = params[:tool_id]
    if @tool.reviews.empty?
      params[:review][:is_primary] = "true"
    end
    @review = Review.new(params[:review])

    #respond_to do |format|
      if @review.save
        ##flash[:notice] = 'Review was successfully created.'
        ##format.html { redirect_to(@review) }
        #if request.xhr?
  		  #  format.html do
  		  #    render :partial => 'reviews/index', :locals => {:tool => @tool, :review => nil}
  		  #  end  
        #end
        #format.xml  { render :xml => @review, :status => :created, :location => @review }
    #  else
    #    format.html { render :action => "new" }
    #    format.xml  { render :xml => @review.errors, :status => :unprocessable_entity }
      end
    #end
  end

  # PUT /reviews/1
  # PUT /reviews/1.xml
  def update
    params[:review][:author_ids] ||= []
    @review = Review.find(params[:id])
    @tool = Tool.find(params[:tool_id])   
    #respond_to do |format|
      if @review.update_attributes(params[:review])      
    #    #flash[:notice] = 'Review was successfully updated.'
    #    #format.html { redirect_to(@review) }
    #    if request.xhr?
  	#	    format.html do
  	#	      render :partial => 'reviews/index', :locals => {:tool => @tool, :review => nil}
  	#      end
  	#    else
  	#      format.html do
  	#        redirect_to tool_url(@tool)
  	#      end
  	#    end      
    #    format.xml  { head :ok }
    #  else
    #    format.html { render :action => "edit" }
    #    format.xml  { render :xml => @review.errors, :status => :unprocessable_entity }
      end
    #end
  end

  # DELETE /reviews/1
  # DELETE /reviews/1.xml
  def destroy
    @review = Review.find(params[:id])
    @tool = Tool.find(params[:tool_id])   
    @review.destroy
    #respond_to do |format|
    #  #format.html { redirect_to(reviews_url) }
    #  format.html do
    #    if request.xhr?
 		#      render :partial => 'reviews/index', :locals => {:tool => @tool, :review => nil}	  
    #    else
 		#      redirect_to tool_url(@tool)           
    #    end
    #  end      
    #  format.xml  { head :ok }
    #end
  end
  
  def add_author
    #@authors = Person.find(:all, :order => 'name')
    @authors = Person.order('name')
    #render :partial => 'authors_selector', :locals => {:selected => nil}
  end

  def contract
    @tool = Tool.find(params[:tool_id])   
    @d = Review.find(params[:id])
    #render :partial => 'contracted', :locals => {:tool => tool, :d => d}
    # NO LONGER NECESSARY: contracted. rendering contract.js.erb
  end
  
  def expand
    @tool = Tool.find(params[:tool_id])   
    @d = Review.find(params[:id])
    @review =  Review.find(params[:id])
    # NO LONGER NECESSARY: render_reviews. rendering expand.js.erb
  end
 
  def contract_show
    @tool = Tool.find(params[:tool_id])   
    @d = Review.find(params[:id])
    #render :partial => 'show_contracted', :locals => {:tool => tool, :d => d}
    # NO LONGER NECESSARY: render_reviews. rendering contract_show.js.erb
  end
  
  def expand_show
    @tool = Tool.find(params[:tool_id])   
    @d = Review.find(params[:id])
    @review =  Review.find(params[:id])
    #render_reviews_show
    # NO LONGER NECESSARY: render_reviews_show. rendering expand_show.js.erb
  end

  
  private
  
  def render_reviews
    #find a way to save selected expanded review
    render :update do |page|
	    yield(page) if block_given?
	    page.replace_html 'descriptions_div', :partial => 'reviews/index', :locals => { :tool => @tool, :review => @d}
	  end
	end  

  def render_reviews_show
    #find a way to save selected expanded review
    render :update do |page|
	    yield(page) if block_given?
	    page.replace_html 'descriptions_div', :partial => 'reviews/show_reviews', :locals => { :tool => @tool, :review => @d}
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
