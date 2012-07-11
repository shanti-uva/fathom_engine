class LineItemsController < ApplicationController

  before_filter :login_required, :find_entity, :authorize_edit
  
  def index
    #@line_items = LineItem.find(:all, :conditions => [ 'category = ? and person_profile_id = ?', params[:category], @entity.person_profile.id ])  
    @line_items = LineItem.where("category = ? and person_profile_id = ?", params[:category], @entity.person_profile.id)
    @category = params[:category]
  end

  # POST /entity/1/line_items
  def create
    @line_item = LineItem.new(params[:line_item])
    @line_item.person_profile_id = @entity.person_profile.id
        
    respond_to do |format|
       if @line_item.save
         flash[:notice] = 'Item was successfully added.'
         format.html { redirect_to( :action => 'index', :person_id => @entity_id, :category => @line_item.category ) }
       else
         format.html { redirect_to( :action => 'index', :person_id => @entity_id, :category => @line_item.category ) }
       end
     end
  end

  # PUT /entity/1/line_items/1
  def update    
    @line_item = @entity.person_profile.line_items.find(params[:id])

    #TODO prevent unauthorized user from updating links
        
    respond_to do |format|
      if @line_item.update_attributes(params[:line_item])
        flash[:notice] = 'Item was successfully updated.'
        format.html { redirect_to( :action => 'index', :person_id => @entity_id, :category => @line_item.category ) }
      else
        format.html { redirect_to( :action => 'index', :person_id => @entity_id, :category => @line_item.category ) }
      end
    end
  end

  # DELETE /entity/1/line_items/1
  def destroy
    @line_item = @entity.person_profile.line_items.find(params[:id])

    #TODO prevent unauthorized user from destroying links

    @line_item.destroy
    redirect_to( :action => 'index', :person_id => @entity_id, :category => @line_item.category ) 
  end
  
  def remove_item

     @line_item = @entity.person_profile.line_items.find(params[:id])
     @line_item.destroy
     init_line_items
     @person = @entity
     
     #render :update do |page|
 	   #  #page.replace_html 'credentials_div', :partial => 'common/dynamic_list', :object => @credentials, :locals => { :category => 'credentials' }
     #  case @line_item.category 
     #  when "positions"
     #    page.replace_html 'positions_div', :partial => 'common/dynamic_list', :object => @positions, :locals => { :category => 'positions' }
     #  when "credentials"
     #    page.replace_html 'credentials_div', :partial => 'common/dynamic_list', :object => @credentials, :locals => { :category => 'credentials' }
     #  when "affiliations"  
     #    page.replace_html 'affiliations_div', :partial => 'common/dynamic_list', :object => @affiliations, :locals => { :category => 'affiliations' }          
     #  end
 	  #end
   end

   def add_item
     
     @line_item = LineItem.new(params[:line_item])
     @line_item.person_profile_id = @entity.person_profile.id
     @person = @entity
     if @line_item.save
       init_line_items
       #render :update do |page|
 	    #  #page.replace_html 'credentials_div', "algun texto nuevo"
 	    #  case params[:line_item][:category]
      #   when "positions"
      #     @div_replaced = "positions_div"
      #     page.replace_html 'positions_div', :partial => 'common/dynamic_list', :object => @positions, :locals => { :category => params[:line_item][:category] }
      #   when "credentials"
      #     @div_replaced = "credentials_div"
      #     page.replace_html 'credentials_div', :partial => 'common/dynamic_list', :object => @credentials, :locals => { :category => params[:line_item][:category] }
      #   when "affiliations"  
      #     @div_replaced = "affiliations_div"
      #     page.replace_html 'affiliations_div', :partial => 'common/dynamic_list', :object => @affiliations, :locals => { :category => params[:line_item][:category] }          
      #   end
 	    #end
 	  end
   end
  
  private
  
  def find_entity()
    @entity_id = params[:person_id]
    @entity = Entity.find(@entity_id)
  end
  
  def init_line_items()
    line_items = @entity.person_profile.line_items
    @positions = line_items.select { |item| item.category == 'positions' }
    @credentials = line_items.select { |item| item.category == 'credentials' }
    @affiliations = line_items.select { |item| item.category == 'affiliations' }  
  end
  
  def authorize_edit()
    unless allowed_to_edit?(@entity)
      redirect_to(@entity)
    end
  end
  
end
