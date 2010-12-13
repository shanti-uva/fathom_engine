class AddPeopleEmail < ActiveRecord::Migration
  def self.up
    add_column :person_profiles, :email, :string
  end

  def self.down
    remove_column :person_profiles, :email
  end
end