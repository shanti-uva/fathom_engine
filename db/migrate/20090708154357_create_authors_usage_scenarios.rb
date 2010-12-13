class CreateAuthorsUsageScenarios < ActiveRecord::Migration
  def self.up
    create_table :authors_usage_scenarios, :id => false do |t|
      t.references :author, :null => false  # author is an User
      t.references  :usage_scenario, :null => false  
    end
    add_index :authors_usage_scenarios, [:author_id, :usage_scenario_id], :unique => true
  end

  def self.down
    drop_table :authors_usage_scenarios
  end
end