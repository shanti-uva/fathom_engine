class ProfessionalProfile < ActiveRecord::Base
  belongs_to :professional_profile_link 
  has_many :professional_profile_links
  has_many :person_profiles, :through => :professional_profile_links
end


# == Schema Info
# Schema version: 20100214201124
#
# Table name: professional_profiles
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime