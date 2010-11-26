class Subject < ActiveRecord::Base
  has_many :links, :class_name=>'SubjectLink', :dependent=>:destroy
end

# == Schema Info
# Schema version: 20100214201124
#
# Table name: subjects
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime