class ProfileInterests < ActiveRecord::Migration
  def self.up
    add_column "project_profiles", "interests", :text
    add_column "person_profiles", "interests", :text
  end

  def self.down
    remove_column "project_profiles", "interests"
    remove_column "person_profiles", "interests"
  end
end