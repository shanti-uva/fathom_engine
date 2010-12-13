class CreateDisciplinesProjectProfiles < ActiveRecord::Migration
  def self.up
     create_table :disciplines_project_profiles do |t|
        t.integer :discipline_id
        t.integer :project_profile_id
        t.timestamps
      end
  end

  def self.down
      drop_table :disciplines_project_profiles
  end
end