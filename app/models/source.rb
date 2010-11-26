class Source < ActiveRecord::Base
  validates_presence_of :resource_id, :resource_type, :mms_id
  #validates_presence_of :start_page
  #validates_presence_of :language_id, :creator_id
  belongs_to :resource, :polymorphic => true 
  #belongs_to :creator, :class_name => 'User', :foreign_key => 'creator_id'
  #belongs_to :language
  has_many :translated_sources, :dependent => :destroy
end


# == Schema Info
# Schema version: 20100214201124
#
# Table name: sources
#
#  id            :integer(4)      not null, primary key
#  mms_id        :integer(4)
#  resource_id   :integer(4)
#  end_line      :integer(4)
#  end_page      :integer(4)
#  note          :text
#  passage       :text
#  resource_type :string(255)
#  start_line    :integer(4)
#  start_page    :integer(4)
#  volume_number :integer(4)
#  created_at    :datetime
#  updated_at    :datetime