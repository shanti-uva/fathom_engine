class Review < ActiveRecord::Base
  validates_presence_of :content, :tool_id
  belongs_to :tool
  has_and_belongs_to_many :authors, :class_name => 'Person', :join_table => 'authors_reviews', :association_foreign_key => 'author_id' 
  has_many :sources, :as => :resource 
end


# == Schema Info
# Schema version: 20100214201124
#
# Table name: reviews
#
#  id         :integer(4)      not null, primary key
#  tool_id    :integer(4)      not null
#  content    :text
#  is_primary :boolean(1)      not null
#  title      :string(255)
#  created_at :datetime
#  updated_at :datetime