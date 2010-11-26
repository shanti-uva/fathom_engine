class DisciplinesPersonProfile < ActiveRecord::Base
  
  belongs_to :discipline
  belongs_to :person_profile
  
end

# == Schema Info
# Schema version: 20100214201124
#
# Table name: disciplines_person_profiles
#
#  id                :integer(4)      not null, primary key
#  discipline_id     :integer(4)
#  person_profile_id :integer(4)
#  created_at        :datetime
#  updated_at        :datetime