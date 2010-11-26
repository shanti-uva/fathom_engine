class Language < ActiveRecord::Base
  validates_presence_of :title

end


# == Schema Info
# Schema version: 20100214201124
#
# Table name: languages
#
#  id         :integer(4)      not null, primary key
#  code       :string(3)       not null
#  locale     :string(6)       not null
#  title      :string(100)     not null
#  created_at :datetime
#  updated_at :datetime