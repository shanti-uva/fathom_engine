class CreateDisciplines < ActiveRecord::Migration
  def self.up
    create_table :disciplines do |t|
      t.string :name
      t.timestamps
    end
    
    # populate with initial disciplines
    [ "English", "Media Studies", "Computer Science", "History", "Religious Studies" ].each { |name|
      discipline = Discipline.new
      discipline.name = name
      discipline.save!
    }  
  end

  def self.down
    drop_table :disciplines
  end
end
