class Organization < Project
  
  has_many :relationships
  has_many :people, :through => :relationships
  has_many :projects, :through => :relationships
  
  attr_accessor :subproject_list
  attr_accessible :subproject_list
  
  attr_accessor :project_ids_to_delete
  attr_accessible :project_ids_to_delete
  def project_ids_to_delete=(project_ids)
    relationships.each do |relationship|
      next unless relationship.project
      relationships.delete(relationship) if project_ids.include?(relationship.project.id.to_s)
    end
  end
  
end

# == Schema Info
# Schema version: 20100214201124
#
# Table name: entities
#
#  id         :integer(4)      not null, primary key
#  image_id   :integer(4)
#  user_id    :integer(4)
#  name       :string(255)
#  type       :string(255)
#  created_at :datetime
#  updated_at :datetime