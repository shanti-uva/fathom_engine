class AddToolIdToRelationship < ActiveRecord::Migration
  def self.up
    add_column :relationships, :tool_id, :integer
  end

  def self.down
    remove_column :relationships, :tool_id
  end
end
