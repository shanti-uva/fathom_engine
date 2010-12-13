class AddProjectProfileHistory < ActiveRecord::Migration
  def self.up
    add_column :project_profiles, :history, :text
  end

  def self.down
    remove_column :project_profiles, :history
  end
end
