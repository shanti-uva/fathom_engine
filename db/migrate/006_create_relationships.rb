class CreateRelationships < ActiveRecord::Migration
  def self.up
    create_table :relationships do |t|
      t.integer :project_id
      t.integer :person_id
      t.integer :organization_id
      t.integer :relation_type_id
      t.string :description
      t.integer :created_by
      t.timestamps
    end
  end

  def self.down
    drop_table :relationships
  end
end
