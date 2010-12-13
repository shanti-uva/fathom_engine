class CreateProjectProfiles < ActiveRecord::Migration
  def self.up
    create_table :project_profiles do |t|
      t.string :home_page
      t.text :technologies
      t.text :overview
      t.text :current_directions
      t.text :outcomes
      t.text :address
      t.string :phone
      t.string :fax
      t.string :contact_email
      t.integer :project_id
      t.timestamps
    end
    
    projects = Project.find(:all)
    projects = projects + Organization.find(:all)

    # Make profiles for all existing projects.
    projects.each { |project| 
      project.create_project_profile()
    }
    
  end

  def self.down
    drop_table :project_profiles
  end
end
