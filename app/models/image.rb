class Image < ActiveRecord::Base

  has_one :entity
  
  has_attachment :content_type => :image, 
                 :storage => :file_system,
                 :path_prefix => 'public/uploads',
                 :max_size => 500.kilobytes,
                 :resize_to => '180x180',
                 :thumbnails => { :thumb => '60x60', :smaller => '35x35', :micro => '25x25' }

  validates_as_attachment
  
  PERSON_PLACEHOLDER = 1
  PROJECT_PLACEHOLDER = 3
  
end

# == Schema Info
# Schema version: 20100214201124
#
# Table name: images
#
#  id           :integer(4)      not null, primary key
#  parent_id    :integer(4)
#  content_type :string(255)
#  filename     :string(255)
#  height       :integer(4)
#  size         :integer(4)
#  thumbnail    :string(255)
#  width        :integer(4)
#  created_at   :datetime
#  updated_at   :datetime