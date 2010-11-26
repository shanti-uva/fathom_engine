class Relationship < ActiveRecord::Base
  belongs_to :person
  belongs_to :project  
  belongs_to :organization
  belongs_to :tool
  
  def self.add_person_to_project(person,project)
    relation = Relationship.new
    relation.person = person
    relation.project = project
    project.relationships << relation
    relation
  end
  
  def self.add_person_to_tool(person,tool)
    relation = Relationship.new
    relation.person = person
    relation.tool = tool
    tool.relationships << relation
    relation
  end
  
  def self.add_project_to_organization(project,organization)
    relation = Relationship.new
    relation.project = project
    relation.organization = organization
    organization.relationships << relation
    relation
  end

  def self.add_person_to_organization(person,organization)
    relation = Relationship.new
    relation.person = person
    relation.organization = organization
    organization.relationships << relation
    relation
  end
    
  def self.remove_person_from_project(person, project)
    Relationship.delete_all ["person_id = ? and project_id = ?", person.id, project.id]
  end
  
  def self.remove_person_from_tool(person, tool)
    Relationship.delete_all ["person_id = ? and tool_id = ?", person.id, tool.id]
  end
  
  def self.remove_project_from_organization( project, organization )
    Relationship.delete_all ["project_id = ? and organization_id = ?", project.id, organization.id]
  end
  
  def self.remove_person_from_organization( person, organization )
    Relationship.delete_all ["person_id = ? and organization_id = ?", person.id, organization.id ]
  end
  
  def self.relations()
    Relationship.find(:all).map { |relationship|
      if relationship.project and relationship.person
        { :to => relationship.project.node_id, :from => relationship.person.node_id }
      elsif relationship.tool and relationship.person
        { :to => relationship.tool.node_id, :from => relationship.person.node_id }
      elsif relationship.project and relationship.organization
        { :to => relationship.organization.node_id, :from => relationship.project.node_id }
      elsif relationship.person and relationship.organization
        { :to => relationship.organization.node_id, :from => relationship.person.node_id }
      end      
    }.compact
  end    
        
end


# == Schema Info
# Schema version: 20100214201124
#
# Table name: relationships
#
#  id               :integer(4)      not null, primary key
#  organization_id  :integer(4)
#  person_id        :integer(4)
#  project_id       :integer(4)
#  relation_type_id :integer(4)
#  tool_id          :integer(4)
#  created_by       :integer(4)
#  description      :string(255)
#  created_at       :datetime
#  updated_at       :datetime