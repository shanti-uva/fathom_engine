class CreateProfessionalProfiles < ActiveRecord::Migration
  def self.up
    create_table :professional_profiles do |t|
      t.column :name, :string
      t.timestamps
    end
    
    Fixtures.create_fixtures(File.dirname(__FILE__), "professional_profiles") 
  end

  def self.down
    drop_table :professional_profiles
  end
end
