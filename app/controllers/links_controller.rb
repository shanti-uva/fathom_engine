class LinksController < ApplicationController

  before_filter :login_required, :find_entity, :authorize_edit
    
  # GET /entity/1/links/new
  def new
    @link = Link.new
  end
  
  # GET /entity/1/links/1/edit
  def edit
    @link = @entity.links.find(params[:id])
  end

  # POST /entity/1/links
  def create
    @link = Link.new(params[:link])
    
    #TODO cgi escape the url label
    
    @link.entity_id = @entity_id
        
    respond_to do |format|
       if @link.save
         flash[:notice] = 'Link was successfully added.'
         format.html { redirect_to(@entity) }
       else
         format.html { redirect_to(@entity) }
       end
     end
  end

  # PUT /entity/1/links/1
  def update    
    @link = @entity.links.find(params[:id])

    #TODO prevent unauthorized user from updating links
        
    respond_to do |format|
      if @link.update_attributes(params[:link])
        flash[:notice] = 'Link was successfully updated.'
        format.html { redirect_to(@entity) }
      else
        format.html { redirect_to(@entity) }
      end
    end
  end

  # DELETE /entity/1/links/1
  def destroy
    @link = @entity.links.find(params[:id])

    #TODO prevent unauthorized user from destroying links

    @link.destroy
    redirect_to(@entity) 
  end
  
  private
  
  def find_entity()
    @entity_id = params[:person_id]
    @entity = Entity.find(@entity_id)
  end
  
  def authorize_edit()
    unless allowed_to_edit?(@entity)
      redirect_to(@entity)
    end
  end
    
end
