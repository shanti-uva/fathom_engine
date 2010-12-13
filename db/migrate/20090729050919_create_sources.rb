class CreateSources < ActiveRecord::Migration
  def self.up
    create_table :sources do |t|
      t.integer :resource_id 
      t.string  :resource_type
      t.integer :mms_id
      t.integer :volume_number
      t.integer :start_page
      t.integer :start_line
      t.integer :end_page
      t.integer :end_line
      t.text    :passage
      t.text    :note

      t.timestamps
    end
  end

  def self.down
    drop_table :sources
  end
end
