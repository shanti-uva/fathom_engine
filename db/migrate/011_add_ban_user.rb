class AddBanUser < ActiveRecord::Migration
  def self.up
    add_column :users, :banned, :boolean
  end

  def self.down
    remove_column :users, :banned
  end
end
