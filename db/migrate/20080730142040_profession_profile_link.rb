class ProfessionProfileLink < ActiveRecord::Migration
  def self.up
      create_table :professional_profile_links do |t|
        t.column :professional_profile_id,  :integer
        t.column :person_profile_id,        :integer
        t.timestamps
      end
  end

  def self.down
   drop_table :professional_profile_links
  end
end
