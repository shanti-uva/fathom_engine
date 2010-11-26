class DisciplinesProjectProfile < ActiveRecord::Base
  
  belongs_to :discipline
  belongs_to :project_profile
  
end

# == Schema Info
# Schema version: 20100214201124
#
# Table name: disciplines_project_profiles
#
#  id                 :integer(4)      not null, primary key
#  discipline_id      :integer(4)
#  project_profile_id :integer(4)
#  created_at         :datetime
#  updated_at         :datetime