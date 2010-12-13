class AddAccessLevel < ActiveRecord::Migration
  def self.up
    add_column :users, :access_level, :string
    add_column :users, :request_full, :boolean
  end

  def self.down
    remove_column :users, :access_level
    remove_column :users, :request_full
  end
end
