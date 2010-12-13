class AddBackgroundToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :background, :text
  end

  def self.down
    remove_column :users, :background
  end
end
