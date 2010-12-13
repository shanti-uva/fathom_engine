class CreateSubjects < ActiveRecord::Migration
  
  def self.up
    
    create_table :subjects do |t|
      t.string :name
      t.timestamps
    end
    
    # populate with initial disciplines
    [ 'Tool Development', 'Scholarly Content', 'Teaching', 'Training', 'Networking' ].each { |name|
      Subject.create :name=>name
    }
  end
  
  def self.down
    drop_table :subjects
  end
  
end