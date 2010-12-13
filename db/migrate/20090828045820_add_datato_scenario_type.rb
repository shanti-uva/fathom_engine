class AddDatatoScenarioType < ActiveRecord::Migration
  def self.up
    ScenarioType.create :title => 'Publication'
  end

  def self.down
    s = ScenarioType.find(:first, :conditions => { :title => "Publication" })
    s.delete
  end
end
