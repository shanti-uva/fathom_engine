class AddCvLink < ActiveRecord::Migration
  def self.up
    add_column :person_profiles, :cv_link, :string
    change_column :person_profiles, :home_page, :string     
  end

  def self.down
    remove_column :person_profiles, :cv_link
    change_column :person_profiles, :home_page, :text     
  end
end
