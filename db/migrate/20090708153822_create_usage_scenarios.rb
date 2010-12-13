class CreateUsageScenarios < ActiveRecord::Migration
  def self.up
    create_table :usage_scenarios do |t|
      t.references :tool, :null => false
      t.text :content
      t.references :scenario_type, :null => false
      t.boolean :is_primary, :null => false, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :usage_scenarios
  end
end
