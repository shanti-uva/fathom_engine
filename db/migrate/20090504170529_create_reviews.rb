class CreateReviews < ActiveRecord::Migration
  def self.up
    create_table :reviews do |t|
      t.references :tool, :null => false
      t.text :content
      t.boolean :is_primary, :null => false, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :reviews
  end
end
