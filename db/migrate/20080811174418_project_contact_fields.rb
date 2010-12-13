class ProjectContactFields < ActiveRecord::Migration
  def self.up
     add_column :project_profiles, :address_one, :string
     add_column :project_profiles, :address_two, :string
     add_column :project_profiles, :city, :string
     add_column :project_profiles, :country, :string
     add_column :project_profiles, :state, :string
     add_column :project_profiles, :zipcode, :string
     add_column :project_profiles, :notes, :text
   end

   def self.down
     remove_column :project_profiles, :address_one
     remove_column :project_profiles, :address_two
     remove_column :project_profiles, :country
     remove_column :project_profiles, :city
     remove_column :project_profiles, :state
     remove_column :project_profiles, :zipcode
     remove_column :project_profiles, :notes
   end
end