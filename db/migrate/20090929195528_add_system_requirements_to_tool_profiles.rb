class AddSystemRequirementsToToolProfiles < ActiveRecord::Migration
  def self.up
    add_column :tool_profiles, :system_requirements, :text
  end

  def self.down
    remove_column :tool_profiles, :system_requirements
  end
end
