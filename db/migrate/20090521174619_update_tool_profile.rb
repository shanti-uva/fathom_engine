class UpdateToolProfile < ActiveRecord::Migration
  def self.up
    ToolProfile.find(:all, :conditions => 'reviews IS NOT NULL').each do |f| 
      if !f.reviews.blank?
        t = Tool.find(f.tool_id) 
        t.reviews.create(:content => f.reviews, :is_primary => true) 
      end
    end
    change_table(:tool_profiles) do |t|
      t.integer :tool_type_id
      t.remove :produced_by
      t.remove :reviews 
    end  
  end

  def self.down
    change_table(:tool_profiles) do |t|
      t.remove :tool_type_id
      t.text :produced_by
      t.text :reviews
    end
  end
end
