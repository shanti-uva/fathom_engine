require 'active_record/fixtures'

class PopulateRelationType < ActiveRecord::Migration
  def self.up 
    down 
    Fixtures.create_fixtures(File.dirname(__FILE__), "relation_types") 
  end 

  def self.down 
    RelationType.delete_all 
  end
end
