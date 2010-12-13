class ProjAndOrgServices < ActiveRecord::Migration
  
  COLS=%W(
    Data
    Tools
    Training
    Events
    Opportunities
    Other
  )
  
  def self.up
    COLS.each{|s|add_column :project_profiles, s.downcase, :text}
  end

  def self.down
    COLS.each{|s|remove_column :project_profiles, s.downcase}
  end
  
end