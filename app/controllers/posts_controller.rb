class PostsController < ApplicationController
  
  before_filter :login_required, :except => [ :index, :show, :show_for_entity ]
  before_filter :find_entity, :except => [ :index ]
  before_filter :main_nav
  before_filter :authorize_edit, :except => [ :index, :show, :show_for_entity ]
  #layout 'main'

  def index
    @posts = Post.find(:all)
    @current_style = :gallery
  end

  # GET /entity/1/posts/new
  def new
    @post = Post.new if @post == nil
    @post.expiration_date = 2.weeks.from_now
    @uses_text_editor = true
    @current_style = :details
  end

  # GET /entity/1/posts/1/edit
  def edit
    @post = @entity.posts.find(params[:id])
    @uses_text_editor = true
    @current_style = :details
  end

  # GET /entity/1/posts/1
  # GET /posts/:id
  def show
    @post = Post.find(params[:id])
    @current_style = :showview #@current_style = :details
  end

  def show_for_entity
    @post = Post.find(params[:id])
    @current_style = :details
  end

  # POST /entity/1/posts
  def create
    @post = Post.new(params[:post])
    @post.entity_id = @entity_id

    respond_to do |format|
      if @post.save
        flash[:notice] = 'Post was successfully added.'
        format.html { redirect_to(@entity) }
      else
        format.html { render :action => "new" }
      end
    end
  end
   
  # PUT /entity/1/posts/1
  def update
    @post = @entity.posts.find(params[:id])

    respond_to do |format|
      if @post.update_attributes(params[:post])
        flash[:notice] = 'Post was successfully updated.'
        format.html { redirect_to(@entity) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # DELETE /entity/1/posts/1
  def destroy
    @post = @entity.posts.find(params[:id])
    @post.destroy
    redirect_to(@entity)
  end

  private
  def find_entity()
    if params[:person_id]
      @entity_id = params[:person_id]
    elsif params[:project_id]
      @entity_id = params[:project_id]
    elsif params[:tool_id]
      @entity_id = params[:tool_id]
    elsif params[:organization_id]
      @entity_id = params[:organization_id]
    end
    
    if !@entity_id.nil?
      @entity = Entity.find(@entity_id)
    else
      @entity = Entity.find(Post.find(params[:id]).entity_id)
    end
  end
   
  def authorize_edit()
    unless allowed_to_edit?(@entity)
      redirect_to(@entity)
    end
  end
   
  def main_nav
    if APPLICATION_DOMAIN != 'shanti.virginia.edu'
      if params[:person_id]
        @current_nav_item = :people
      elsif params[:project_id]
         @current_nav_item = :projects
      elsif params[:tool_id]
        @current_nav_item = :tools
      elsif params[:organization_id]
        @current_nav_item = :organizations
      else
        @current_nav_item = :posts
      end
    else
      @current_nav_item = :home #:uva_profiles
      if params[:person_id]
        #@current_nav_item = :people
        @current_sub_nav_item = :people
      elsif params[:project_id]
        #@current_nav_item = :projects
        @current_sub_nav_item = :projects
      elsif params[:tool_id]
        #@current_nav_item = :tools
        @current_sub_nav_item = :tools
      elsif params[:organization_id]
        #@current_nav_item = :organizations
        @current_sub_nav_item = :organizations
      else
        #@current_nav_item = :posts
        @current_sub_nav_item = :posts
      end
    end
    @login_enabled = true
    @nav_enabled = true
    @profile_view = true
  end
   
end
