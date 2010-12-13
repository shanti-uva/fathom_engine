class RemoveToolProfileScenarios < ActiveRecord::Migration
  def self.up
      ToolProfile.find(:all, :conditions => 'teaching_scenarios IS NOT NULL').each do |f| 
        if !f.teaching_scenarios.blank?
          t = Tool.find(f.tool_id) 
          t.usage_scenarios.create(:content => f.teaching_scenarios, :scenario_type_id => 1, :is_primary => true) 
        end
      end
      ToolProfile.find(:all, :conditions => 'research_scenarios IS NOT NULL').each do |f| 
        if !f.research_scenarios.blank?
          t = Tool.find(f.tool_id) 
          if t.usage_scenarios.empty?
            p = true
          else
            p = false
          end
          t.usage_scenarios.create(:content => f.research_scenarios, :scenario_type_id => 2, :is_primary => p) 
        end
      end
      ToolProfile.find(:all, :conditions => 'engagement_scenarios IS NOT NULL').each do |f| 
        if !f.engagement_scenarios.blank?
          t = Tool.find(f.tool_id) 
          if t.usage_scenarios.empty?
            p = true
          else
            p = false
          end
          t.usage_scenarios.create(:content => f.engagement_scenarios, :scenario_type_id => 3, :is_primary => p) 
        end
      end 
      change_table(:tool_profiles) do |t|
        t.remove :teaching_scenarios
        t.remove :research_scenarios
        t.remove :engagement_scenarios 
      end
  end

  def self.down
    change_table(:tool_profiles) do |t|
      t.text :teaching_scenarios
      t.text :research_scenarios
      t.text :engagement_scenarios
    end
  end
end
