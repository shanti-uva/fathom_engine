class CreateToolProfiles < ActiveRecord::Migration
  def self.up
    create_table :tool_profiles do |t|
      t.text :summary
      t.text :license
      t.text :cost
      t.string :home_page
      t.string :download_page
      t.text :features
      t.text :teaching_scenarios
      t.text :research_scenarios
      t.text :engagement_scenarios
      t.text :version_history
      t.text :reviews
      t.text :technical_details
      t.text :produced_by
      t.text :support
      t.text :developer_resources
      t.text :mailing_list
      t.text :discussion_forums
      t.text :tutorials
      t.text :tips     
      t.text :more_information 
      t.integer :tool_id

      t.timestamps
    end
  end

  def self.down
    drop_table :tool_profiles
  end
end
