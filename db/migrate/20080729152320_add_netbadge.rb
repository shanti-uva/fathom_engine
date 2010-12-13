class AddNetbadge < ActiveRecord::Migration
  def self.up
    add_column :users, :netbadgeid, :string
  end

  def self.down
    remove_column :users, :netbadgeid
  end
end
