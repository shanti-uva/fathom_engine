class ScenarioType < ActiveRecord::Base
  validates_presence_of :title
  
end


# == Schema Info
# Schema version: 20100214201124
#
# Table name: scenario_types
#
#  id         :integer(4)      not null, primary key
#  title      :string(255)
#  created_at :datetime
#  updated_at :datetime