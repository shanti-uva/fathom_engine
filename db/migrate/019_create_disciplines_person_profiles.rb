class CreateDisciplinesPersonProfiles < ActiveRecord::Migration
  def self.up
     create_table :disciplines_person_profiles do |t|
        t.integer :discipline_id
        t.integer :person_profile_id
        t.timestamps
      end
  end

  def self.down
      drop_table :disciplines_person_profiles
  end
end
