class CreateLineItems < ActiveRecord::Migration
  def self.up
    create_table :line_items do |t|
      t.string :text
      t.string :category
      t.integer :person_profile_id
      t.timestamps
    end
  end

  def self.down
    drop_table :line_items
  end
end
