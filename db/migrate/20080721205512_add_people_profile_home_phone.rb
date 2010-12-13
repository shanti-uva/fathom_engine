class AddPeopleProfileHomePhone < ActiveRecord::Migration
  def self.up
    add_column :person_profiles, :home_phone, :string
  end

  def self.down
    remove_column :person_profiles, :home_phone
  end
end