class Tool < Entity
  has_one :tool_profile, :dependent=>:destroy
  has_many :relationships, :dependent=>:destroy
  
  has_many :people, :through => :relationships
  has_many :organizations, :through => :relationships
  has_many :sources, :as => :resource 

  # Multiple review for tools
  has_many :reviews, :dependent => :destroy
  # Multiple usage scenarios for tools
  has_many :usage_scenarios, :dependent => :destroy
  
  attr_accessor :invite_list
  attr_accessible :invite_list
  
  INVITEE_FIELDS = [ :first_name, :last_name, :email ]
  
  attr_accessor :member_ids_to_delete
  attr_accessible :member_ids_to_delete
  def member_ids_to_delete=(member_ids)
    relationships.each do |relationship|
      next unless relationship.person
      relationships.delete(relationship) if member_ids.include?(relationship.person.id.to_s)
    end
  end

  def invitees()
    return [] if invite_list.nil?
  
    # break the list down into lines
    invitees = invite_list.split("\n").map { |line| 
      invitee = {}
      field_index = 0
      # for each line, scan for the invitee fields and construct invitee hash
      line.scan(/[\w@.]+/) do |word|
        if field_index < INVITEE_FIELDS.size
          invitee[INVITEE_FIELDS[field_index]] = word
          field_index = field_index + 1
        end
      end  
      # if this entry was empty, return nil 
      (invitee.keys.size > 0) ? invitee : nil    
    }.compact # remove the nils
    
    # make one more pass to create the full name
    invitees.each { |invitee|  
      invitee[:first_name] = "" if invitee[:first_name].nil?
      invitee[:last_name] = "" if invitee[:last_name].nil?
      space = (invitee[:first_name].blank? or invitee[:last_name].blank?) ? "" : " "
      invitee[:full_name] = "#{invitee[:first_name]}#{space}#{invitee[:last_name]}"
    }
  end
  
  def invite_by_email( invitee, inviter )    
    #AccountMailer.deliver_invite_user( invitee, inviter, self )
    AccountMailer.invite_user( invitee, inviter, self ).deliver
  end
  
  # TODO: Pull indexing into Entity; the only difference between Entity derivatives is
  # the fragments collection.
  # go through every searchable field in the profile and index them

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
      ["Profile", "Summary"] => tool_profile.summary,
      ["Profile", "License"] => tool_profile.license,
      ["Profile", "Cost"] => tool_profile.cost,
      ["Profile", "Features"] => tool_profile.features,
      ["Profile", "Version History"] => tool_profile.version_history,
      ["Profile", "System Requirements"] => tool_profile.system_requirements,
  
      # Technology 
      ["Technology", "Technical Details"] => tool_profile.technical_details,

      # Support
      ["Support", "Support"] => tool_profile.support,
      ["Support", "Developer Resources"] => tool_profile.developer_resources,
      ["Support", "Mailing List"] => tool_profile.mailing_list,
      ["Support", "Discussion Forums"] => tool_profile.discussion_forums,
      ["Support", "Tutorials"] => tool_profile.tutorials,
      ["Support", "Tips"] => tool_profile.tips,
      ["Support", "More Information"] => tool_profile.more_information,      
    }

    aggregated_facets_map = {}
    ProfileTagCombiner::TAG_FIELDS.each do |tag|
      # See if this profile has any relevant tags in each field.
      tag_values = self.tool_profile.send("#{tag.to_s.singularize}_list")

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

  # TODO: This is inefficient. Search by entity ID and remove those documents instead.
  def remove_from_index( solr = SolrSearch.new(SOLR_URL), commit = :commit )
   # profile
    solr.remove_document( solr_fragment_id( "Profile", "Summary" ) )
    solr.remove_document( solr_fragment_id( "Profile", "License" ) )
    solr.remove_document( solr_fragment_id( "Profile", "Cost" ) )
    solr.remove_document( solr_fragment_id( "Profile", "Version History" ) )
    solr.remove_document( solr_fragment_id( "Profile", "System Requirements" ) )
    
    # reviews
    #solr.remove_document( solr_fragment_id( "Reviews", "Reviews" ) )
  
    # Technology
     solr.remove_document( solr_fragment_id( "Technology", "Technical Details"  ) )

    # interests
    solr.remove_document( solr_fragment_id( "Interests", "general interests" ) )
    solr.remove_document( solr_fragment_id( "Interests", "technologies of interest" ) )
    solr.remove_document( solr_fragment_id( "Interests", "languages" ) )
    solr.remove_document( solr_fragment_id( "Interests", "developers" ) )
    solr.remove_document( solr_fragment_id( "Interests", "producers" ) )
    solr.remove_document( solr_fragment_id( "Interests", "license_types" ) )
    solr.remove_document( solr_fragment_id( "Interests", "platforms" ) )
    solr.remove_document( solr_fragment_id( "Interests", "operating_systems" ) )
    
    # Support
    solr.remove_document( solr_fragment_id( "Support", "Support" ) )
    solr.remove_document( solr_fragment_id( "Support", "Developer Resources" ) )
    solr.remove_document( solr_fragment_id( "Support", "Mailing List" ) )
    solr.remove_document( solr_fragment_id( "Support", "Discussion Forums" ) )
    solr.remove_document( solr_fragment_id( "Support", "Tutorials" ) )
    solr.remove_document( solr_fragment_id( "Support", "Tips" ) )
    solr.remove_document( solr_fragment_id( "Support", "More Information" ) )

    
    solr.commit if commit == :commit
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