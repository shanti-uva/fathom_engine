class PostKind < ActiveRecord::Base
end


# == Schema Info
# Schema version: 20100214201124
#
# Table name: post_kinds
#
#  id              :integer(4)      not null, primary key
#  post_kind_id    :string(255)
#  post_kind_value :string(255)
#  created_at      :datetime
#  updated_at      :datetime