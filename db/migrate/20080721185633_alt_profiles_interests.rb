class AltProfilesInterests < ActiveRecord::Migration
  def self.up
    remove_column :person_profiles, :research_interests
    
    # project profiles
    add_column :project_profiles, :time_periods_of_interest, :text
    add_column :project_profiles, :places_of_interest, :text
    
    # person profiles
    add_column :person_profiles, :time_periods_of_interest, :text
    add_column :person_profiles, :places_of_interest, :text
  end

  def self.down
    add_column :person_profiles, :research_interests, :text
    
    # project profiles
    remove_column :project_profiles, :time_periods_of_interest
    remove_column :project_profiles, :places_of_interest
    
    # person profiles
    remove_column :person_profiles, :time_periods_of_interest
    remove_column :person_profiles, :places_of_interest
  end
end