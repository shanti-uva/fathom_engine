class PeopleAndSponsors4ProjectProfile < ActiveRecord::Migration
  
  def self.up
    add_column :project_profiles, :people, :text
    add_column :project_profiles, :sponsors, :text
  end

  def self.down
    remove_column :project_profiles, :people
    remove_column :project_profiles, :sponsors
  end
  
end