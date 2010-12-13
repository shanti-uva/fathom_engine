class CreateSubjectLinks < ActiveRecord::Migration
  
  def self.up
    create_table :subject_links do |t|
      t.integer :subject_id, :null=>false
      t.integer :subjectable_id, :null=>false
      t.string :subjectable_type, :null=>false
      t.timestamps
    end
    
  end
  
  def self.down
    drop_table :subject_links
  end
  
end