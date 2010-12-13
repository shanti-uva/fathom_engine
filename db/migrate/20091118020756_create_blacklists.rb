class CreateBlacklists < ActiveRecord::Migration
  def self.up
    create_table :blacklists do |t|
      t.string :email
      t.string :first_name
      t.string :middle_initial
      t.string :last_name
      t.integer :attempts
      t.date :last_attempt

      t.timestamps
    end
  end

  def self.down
    drop_table :blacklists
  end
end
