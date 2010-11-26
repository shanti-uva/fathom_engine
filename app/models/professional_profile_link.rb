class ProfessionalProfileLink < ActiveRecord::Base
  belongs_to :professional_profile
  belongs_to :person_profile
end


# == Schema Info
# Schema version: 20100214201124
#
# Table name: professional_profile_links
#
#  id                      :integer(4)      not null, primary key
#  person_profile_id       :integer(4)
#  professional_profile_id :integer(4)
#  created_at              :datetime
#  updated_at              :datetime