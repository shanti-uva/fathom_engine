class SubjectLink < ActiveRecord::Base
  belongs_to :subject
  belongs_to :subjectable, :polymorphic=>true
end

# == Schema Info
# Schema version: 20100214201124
#
# Table name: subject_links
#
#  id               :integer(4)      not null, primary key
#  subject_id       :integer(4)      not null
#  subjectable_id   :integer(4)      not null
#  subjectable_type :string(255)     not null
#  created_at       :datetime
#  updated_at       :datetime