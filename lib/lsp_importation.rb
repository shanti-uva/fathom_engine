# LspImportation
require 'config/environment'
require 'csv'

module LspImportation
  def self.do_lsp_importation(filename, organizationId)
    

    field_names = nil
    CSV.open(filename, 'r', "\t") do |row|

      if field_names.nil?
        field_names = row
        next
      end
      fields = Hash.new
      row.each_with_index { |field, index| fields[field_names[index]] = field if !field.blank? }
      first_name = fields['first_name']
      last_name = fields['last_name']
      department_school = fields['department_school'] + " UVa"
      area_group = "LSP-Area " + fields['area_group']
      computing_id = fields['computing_id'].downcase
      email = computing_id + "@virginia.edu"
      phone = fields['phone']
      #rules for phone
      phone_size = phone.size
      case phone_size
      when 8
        converted_phone = "1-434-" + phone
      when 14
        converted_phone = "1-" + phone
      else
        case phone[0,1]
        when "4"
          converted_phone = "1-434-92" + phone
        when "3"
          converted_phone = "1-434-24" + phone
        when "2"
          converted_phone = "1-434-98" + phone   
        end
      end  
      lsp_pro = !fields['lsp_pro'].blank? #if it has something then yes, otherwise no
      
      user = User.find(:first, :conditions => [ 'netbadgeid = ?', computing_id] )
        
      if user.nil? #since it doesn't exist we will create the user, person_profile and line_items
        
        #Create User with basic data
        user = User.new({ :login => email, 
            :email => email,
            :netbadgeid => computing_id 
        })
      
        #grant them Full Access Level
        user.access_level = 'Full'
        #set them as a private profile
        user.private_profile = true
        #set the user background as 'LSP_IMPORTED' so i can identify them as a microcommunity later on
        user.background = "LSP_IMPORTED"
        
        #create a person related to the user
        person = user.create_person
        person.name = "#{first_name} #{last_name}"
          
        #create the person's profile
        person.create_person_profile()
        person.person_profile.first_name = first_name
        person.person_profile.last_name = last_name
        person.person_profile.professional_profile = "Technologist"
        person.person_profile.title = "Local Support Partner"
        person.person_profile.email = email
        person.person_profile.office_phone = converted_phone
           
        #creating the ine items that will contain the affiliations
        department_line_item = LineItem.new({:category => "affiliations", :text => department_school})
        department_line_item.person_profile_id = person.person_profile.id
        
        area_line_item = LineItem.new({:category => "affiliations", :text => area_group})
        area_line_item.person_profile_id = person.person_profile.id
     
        #Save the user data
        if user.save
          #if the user is successfully saved then save the line items associated to it
          department_line_item.save
          area_line_item.save
          unless organizationId.blank?
            @organization = Organization.find(organizationId) 
            unless person.organizations.include?(@organization)
              relation = Relationship.add_person_to_organization(person,@organization)
              relation.save!
            end   
          end
        else
          #I should show an error message
          #self.send(:new)
          #render :action => 'new'
        end
      else #if a person_profile with that netbade_id exist we will add the affiliations only
        person = Person.find(:first, :conditions => [ 'user_id = ?', user.id] )
        if !person.nil?
          #add relationship to existing person 
          unless organizationId.blank?
            @organization = Organization.find(organizationId) 
            unless @organization.blank?
              unless person.organizations.include?(@organization)
                relation = Relationship.add_person_to_organization(person,@organization)
                relation.save!
              end 
            end  
          end
          if person.person_profile.email.blank?
            person.person_profile.email = email
          end
          if person.person_profile.office_phone.blank? 
            person.person_profile.office_phone = converted_phone
          end
          person.person_profile.save
          person.user.background = "LSP_IMPORTED"
          person.user.save
          prev_department_line_item = LineItem.find(:first, :conditions => [ 'person_profile_id = ? and text = ? and category = ?', person.person_profile.id, department_school, "affiliations"] )
          if prev_department_line_item.nil?
            department_line_item = LineItem.new({:category => "affiliations", :text => department_school})
            department_line_item.person_profile_id = person.person_profile.id
            department_line_item.save
          end
          prev_area_line_item = LineItem.find(:first, :conditions => [ 'person_profile_id = ? and text = ? and category = ?', person.person_profile.id, area_group, "affiliations"] )
          if prev_area_line_item.nil?
            area_line_item = LineItem.new({:category => "affiliations", :text => area_group})          
            area_line_item.person_profile_id = person.person_profile.id
            area_line_item.save
          end
        end
      end
    end #do
  end #do_lsp_importation
  
end #module