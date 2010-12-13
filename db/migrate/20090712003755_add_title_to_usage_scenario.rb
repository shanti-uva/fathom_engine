class AddTitleToUsageScenario < ActiveRecord::Migration
  def self.up
    add_column :usage_scenarios, :title, :string
  end

  def self.down
    remove_column :usage_scenarios, :title
  end
end
