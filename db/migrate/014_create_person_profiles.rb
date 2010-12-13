class CreatePersonProfiles < ActiveRecord::Migration
  def self.up
    create_table :person_profiles do |t|
      t.string :first_name
      t.string :middle_initial
      t.string :last_name
      t.string :title
      t.text :professional_profile
      t.text :home_page
      t.text :overview
      t.text :focus
      t.text :activities_overview
      t.text :goals
      t.integer :person_id
      t.timestamps
    end
    
    people = Person.find(:all)
    
    # Make profiles for all existing users.
    people.each { |person| 
      person.create_person_profile()
    }
    
  end

  def self.down
    drop_table :person_profiles
  end
end
