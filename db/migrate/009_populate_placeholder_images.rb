require 'active_record/fixtures'

class PopulatePlaceholderImages < ActiveRecord::Migration
  def self.up 
    down 
    Fixtures.create_fixtures(File.dirname(__FILE__), "images") 
  end 

  def self.down 
    Image.delete_all 
  end
end
