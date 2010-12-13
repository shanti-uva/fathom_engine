class CreateEntities < ActiveRecord::Migration
  def self.up
    create_table :entities do |t|
      t.string :name
      t.string :type
      t.integer :image_id
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :entities
  end
end
