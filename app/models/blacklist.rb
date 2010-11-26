class Blacklist < ActiveRecord::Base
end


# == Schema Info
# Schema version: 20100214201124
#
# Table name: blacklists
#
#  id             :integer(4)      not null, primary key
#  attempts       :integer(4)
#  email          :string(255)
#  first_name     :string(255)
#  last_attempt   :date
#  last_name      :string(255)
#  middle_initial :string(255)
#  created_at     :datetime
#  updated_at     :datetime