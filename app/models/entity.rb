class Entity < ActiveRecord::Base
  
  belongs_to :image#, :dependent=>:destroy
  has_many :links, :dependent=>:destroy
  has_many :posts, :dependent=>:destroy
  belongs_to :user
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  attr_accessible :name

  INDEXED_TYPES = ["people", "projects", "organizations", "tools"]

  def last_updated_on
    updated_at
  end
  
  def thumb_src
    image ? image.public_filename(:thumb) : placeholder_image_thumb
  end
  
  def image_src
    image ? image.public_filename : placeholder_image
  end
  
  def placeholder_image
    "entity_placeholders/#{self.class.to_s.underscore}_placeholder.jpg"
  end
  
  def placeholder_image_thumb
    "entity_placeholders/#{self.class.to_s.underscore}_placeholder_thumb.jpg"
  end
  
  def node_id
    "node#{id}"
  end
  
  def solr_fragment_id( field_set, field_name )
    "#{id}:#{field_set}:#{field_name}"
  end

  def solr_entity_id()
    "#{id}"
  end

  # taken from ERB::Util --> http://www.ruby-doc.org/stdlib/libdoc/erb/rdoc/classes/ERB/Util.html
  def html_escape(s)
    s.to_s.gsub(/&/, "&amp;").gsub(/\"/, "&quot;").gsub(/>/, "&gt;").gsub(/</, "&lt;")
  end
  
  # generate a Solr doc hash for this field
  def generate_solr_field_doc(field_set, field_name, field_value)
    { :id => solr_fragment_id( field_set, field_name ),
      :docType => SearchResult::FRAGMENT_TYPE,
      :entityID => id,
      :entityType => self[:type],
      :entityName => name,
      :fieldSet => field_set, # this seems to map to the "tab" variable in an entities profile
      :fieldName => field_name,
      :displayText => html_escape(field_value),

      # html_escape, then strip html tags
      :text => html_escape(field_value).gsub(/<\/?[^>]*>/, ""),
      :imageURL => thumb_src,
      
      :type_facet => self.class.to_s.humanize
    }
  end

  def generate_solr_entity_doc(aggregated_text = "")
    { :id => solr_entity_id(),
      :docType => SearchResult::ENTITY_TYPE,
      :displayText => html_escape(aggregated_text),
      :text => html_escape(aggregated_text).gsub(/<\/?[^>]*>/, ""),
      :type_facet => self.class.to_s.humanize,
      :imageURL => thumb_src,
      :entityID => id,
      :entityType => self[:type],
      :entityName => name,
      :name_t => name
    }
  end

  def generate_profile_tags_doc()
    # TODO:
    #    ProfileTagCombiner::TAG_FIELDS.each do |tag|
    #      # See if this profile has any relevant tags in each field.
    #      tag_values = self.project_profile.send("#{tag.to_s.singularize}_list")
    #
    #      # Don't try to index if there aren't any tags in this field.
    #      next if tag_values.size == 0
    #
    #      # Create a Solr doc for this interests field. This name maps to displayText in Solr.
    #      concatenated_tags = tag_values.join(", ")
    #      aggregated_text << concatenated_tags
    #      d = generate_solr_field_doc("Interests", tag.to_s.humanize.downcase, concatenated_tags)
    #
    #      # Create facet fields based on the tag name and add the values array. This is a Solr multiValued field.
    #      d["#{tag}_facet"] = tag_values
    #
    #      # All done.
    #      documents << d
    #    end
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