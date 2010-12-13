class AddProfileFields < ActiveRecord::Migration
  def self.up
    add_column :person_profiles, :works_overview, :text
    add_column :person_profiles, :publications, :text
    add_column :person_profiles, :tools, :text
    add_column :person_profiles, :websites, :text
    add_column :person_profiles, :miscellaneous, :text
    add_column :person_profiles, :research_interests, :text
    add_column :person_profiles, :skills, :text
    add_column :person_profiles, :technologies, :text
    add_column :person_profiles, :notes, :text
  end

  def self.down
    remove_column :person_profiles, :works_overview
    remove_column :person_profiles, :publications
    remove_column :person_profiles, :tools
    remove_column :person_profiles, :websites
    remove_column :person_profiles, :miscellaneous
    remove_column :person_profiles, :research_interests
    remove_column :person_profiles, :skills
    remove_column :person_profiles, :technologies
    remove_column :person_profiles, :notes
  end
end
