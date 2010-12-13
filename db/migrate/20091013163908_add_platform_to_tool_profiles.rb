class AddPlatformToToolProfiles < ActiveRecord::Migration
  def self.up
    add_column :tool_profiles, :platform, :text
  end

  def self.down
    remove_column :tool_profiles, :platform
  end
end
