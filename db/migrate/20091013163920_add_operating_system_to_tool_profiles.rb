class AddOperatingSystemToToolProfiles < ActiveRecord::Migration
  def self.up
    add_column :tool_profiles, :operating_system, :text
  end

  def self.down
    remove_column :tool_profiles, :operating_system
  end
end
