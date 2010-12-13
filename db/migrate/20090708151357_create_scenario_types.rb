class CreateScenarioTypes < ActiveRecord::Migration
  def self.up
    create_table :scenario_types do |t|
      t.string :title

      t.timestamps
    end
    
    # populate with initial usage scenarios types
    [ 'Teaching', 'Research', 'Engagement' ].each { |type|
      ScenarioType.create :title=>type
    }
  end

  def self.down
    drop_table :scenario_types
  end
end
