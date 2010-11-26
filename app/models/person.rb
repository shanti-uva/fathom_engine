class Person < Entity
  
  has_one :person_profile, :dependent => :destroy
  has_many :relationships, :dependent => :destroy
  has_many :projects, :through => :relationships
  has_many :tools, :through => :relationships
  has_many :organizations, :through => :relationships
  
  attr_accessor :request_text

  
  has_and_belongs_to_many :reviews, :join_table => 'authors_reviews', :foreign_key => 'author_id'
  has_and_belongs_to_many :usage_scenarios, :join_table => 'authors_usage_scenarios', :foreign_key => 'author_id'
  has_and_belongs_to_many :translated_sources, :join_table => 'authors_translated_sources', :foreign_key => 'author_id'

  #
  # Just in case the database gets cleared after a migration (db/migrate/009_populate_placeholder_images.rb)
  # this method creates the placeholder if it doesn't exist
  #
=begin
  def self.placeholder_image
    begin
      Image.find(Image::PERSON_PLACEHOLDER)
    rescue ActiveRecord::RecordNotFound
      placeholder = Image.create({
        :id=>1,
        :content_type=>'image/jpeg',
        :filename=>'person_placeholder.jpg',
        :size=>7009,
        :width=>150,
        :height=>200
      })
      Image.create({
        :id=>2,
        :content_type=>'image/jpeg',
        :filename=>'person_placeholder_thumb.jpg',
        :thumbnail=>'thumb',
        :parent_id=>1,
        :size=>4432,
        :width=>38,
        :height=>50
      })
      placeholder
    end
  end
=end
  
  def full_name
    "#{person_profile.first_name} #{person_profile.last_name}"
  end
  
  # 
  # Accepts an array of project ids.
  # This method deletes all relationships associated
  # with the ids in "project_ids"
  # 
  def relationships_to_delete_by_project_ids=(project_ids)
    relationships.each do |relationship|
      next unless relationship.project
      relationships.delete(relationship) if project_ids.include?(relationship.project.id.to_s)
    end
  end
  
  # 
  # Accepts an array of tool ids.
  # This method deletes all relationships associated
  # with the ids in "tool_ids"
  # 
  def relationships_to_delete_by_tool_ids=(tool_ids)
    relationships.each do |relationship|
      next unless relationship.tool
      relationships.delete(relationship) if tool_ids.include?(relationship.tool.id.to_s)
    end
  end
  
  # 
  # Accepts an array of organization ids.
  # This method deletes all relationships associated
  # with the ids in "organization_ids"
  # 
  def relationships_to_delete_by_organization_ids=(organization_ids)
    relationships.each do |relationship|
      next unless relationship.organization
      relationships.delete(relationship) if organization_ids.include?(relationship.organization.id.to_s)
    end
  end
  
  # Index fields for consumption by Solr as Solr documents.
  def index( solr = SolrSearch.new(SOLR_URL), commit = :commit )
    # Add each document we created for commit by Solr.
    solr_documents_list.each do |doc|
      solr.add_document(doc)
    end

    solr.commit if commit == :commit
  end

  def solr_documents_list
    # List of documents to process for Solr.
    documents = []

    # Text from each processed field.
    aggregated_text = []

    # Treat names a little bit differently, and index these separately as a text field.
    name_doc = generate_solr_field_doc("Profile", "Name", name)
    name_doc[:name_t] = name # text field -- indexed, stored and tokenized for name searching
    aggregated_text << name
    documents << name_doc

    fragments = {
      ["Profile", "Title"] => person_profile.title,
      ["Profile", "Profession"] => person_profile.professional_profile,
      ["Profile", "Overview"] => person_profile.overview,

      ["Activities", "Current Focus"] => person_profile.focus,
      ["Activities", "History"] => person_profile.activities_overview,
      ["Activities", "Future Goals"] => person_profile.goals,

      ["Works", "Overview"] => person_profile.works_overview,
      ["Works", "Publications"] => person_profile.publications,
      ["Works", "Websites"] => person_profile.websites,
      ["Works", "Tools"] => person_profile.tools,
      ["Works", "Miscellaneous"] => person_profile.miscellaneous,

      ["Background", "Skills"] => person_profile.skills,
      #TODO background - positions
      #TODO background - education
      #TODO background - memberships

      ["Contact", "City"] => person_profile.city,
      ["Contact", "Country"] => person_profile.country,
      ["Contact", "State"] => person_profile.state,
      ["Contact", "Zipcode"] => person_profile.zipcode,
    }

    aggregated_facets_map = {}
    ProfileTagCombiner::TAG_FIELDS.each do |tag|
      # See if this profile has any relevant tags in each field.
      tag_values = self.person_profile.send("#{tag.to_s.singularize}_list")
      
      # Don't try to index if there aren't any tags in this field.
      next if tag_values.size == 0

      # Create a Solr doc for this interests field. This name maps to displayText in Solr.
      concatenated_tags = tag_values.join(", ")
      aggregated_text << concatenated_tags
      d = generate_solr_field_doc("Interests", tag.to_s.humanize.downcase, concatenated_tags)

      # Create facet fields based on the tag name and add the values array.
      aggregated_facets_map["#{tag}_facet"] = tag_values
      d["#{tag}_facet"] = tag_values

      # All done.
      documents << d
    end

    # Generate a list of documents from each set of fields to be indexed.
    fragments.each { |fields, value|
      aggregated_text << value
      documents << generate_solr_field_doc(fields[0], fields[1], value)
    }

    # Also index a document for this entity that has the same tags.
    d = generate_solr_entity_doc(aggregated_text.join(" "))
    aggregated_facets_map.each { |facet, tags|
      d[facet] = tags
    }
    documents << d

    return documents
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