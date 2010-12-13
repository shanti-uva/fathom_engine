class AddContactField < ActiveRecord::Migration
  def self.up
     add_column :person_profiles, :address_one, :string
     add_column :person_profiles, :address_two, :string
     add_column :person_profiles, :city, :string
     add_column :person_profiles, :country, :string
     add_column :person_profiles, :state, :string
     add_column :person_profiles, :zipcode, :string
     add_column :person_profiles, :office_phone, :string
     add_column :person_profiles, :cell_phone, :string
     add_column :person_profiles, :other_contact, :string
     add_column :person_profiles, :other_contact_type, :string     
   end

   def self.down
     remove_column :person_profiles, :address_one
     remove_column :person_profiles, :address_two
     remove_column :person_profiles, :country
     remove_column :person_profiles, :city
     remove_column :person_profiles, :state
     remove_column :person_profiles, :zipcode
     remove_column :person_profiles, :office_phone
     remove_column :person_profiles, :cell_phone
     remove_column :person_profiles, :other_contact
     remove_column :person_profiles, :other_contact_type     
   end
end
