class LineItem < ActiveRecord::Base
  belongs_to :person_profile
end

# == Schema Info
# Schema version: 20100214201124
#
# Table name: line_items
#
#  id                :integer(4)      not null, primary key
#  person_profile_id :integer(4)
#  category          :string(255)
#  text              :string(255)
#  created_at        :datetime
#  updated_at        :datetime