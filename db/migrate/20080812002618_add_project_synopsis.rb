class AddProjectSynopsis < ActiveRecord::Migration
  def self.up
    add_column "project_profiles", "synopsis", :text
  end

  def self.down
    remove_column "project_profiles", "synopsis"
  end
end
