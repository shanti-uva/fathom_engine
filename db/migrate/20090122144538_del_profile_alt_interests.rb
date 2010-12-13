class DelProfileAltInterests < ActiveRecord::Migration
  
  # remove/add these fields
  def self.field_set; %W(time_periods_of_interest places_of_interest technologies) end
    
  def self.up
    field_set.each do |field_name|
      remove_column "person_profiles", field_name
      remove_column "project_profiles", field_name
    end
  end
  
  def self.down
    field_set.each do |field_name|
      add_column "person_profiles", field_name, :text
      add_column "project_profiles", field_name, :text
    end
  end
end