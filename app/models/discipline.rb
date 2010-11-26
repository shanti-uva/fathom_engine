class Discipline < ActiveRecord::Base
  
  belongs_to :disciplines_person_profile
  has_many :disciplines_person_profiles, :dependent=>:destroy
  has_many :person_profiles, :through => :disciplines_person_profiles 
  
end

# == Schema Info
# Schema version: 20100214201124
#
# Table name: disciplines
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime