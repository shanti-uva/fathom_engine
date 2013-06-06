class Project < Entity
  
  has_one :project_profile, :dependent=>:destroy
  has_many :relationships, :dependent=>:destroy
  
  has_many :people, :through => :relationships
  has_many :organizations, :through => :relationships
  
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
  
  attr_accessor :organization_ids_to_delete
  attr_accessible :organization_ids_to_delete
  def organization_ids_to_delete=(organization_ids)
    relationships.each do |relationship|
      next unless relationship.organization
      relationships.delete(relationship) if organization_ids.include?(relationship.organization.id.to_s)
    end
  end
  
  #
  # Just in case the database gets cleared after a migration (db/migrate/009_populate_placeholder_images.rb)
  # this method creates the placeholder if it doesn't exist
  #
=begin
  def self.placeholder_image
    begin
      Image.find(Image::PROJECT_PLACEHOLDER)
    rescue ActiveRecord::RecordNotFound
      placeholder = Image.create({
        :id=>2,
        :content_type=>'image/jpeg',
        :filename=>'project_placeholder.jpg',
        :size=>12684,
        :width=>189,
        :height=>183
      })
      Image.create({
        :id=>4,
        :content_type=>'image/jpeg',
        :filename=>'project_placeholder_thumb.jpg',
        :thumbnail=>'thumb',
        :parent_id=>3,
        :size=>5479,
        :width=>50,
        :height=>48
      })
      placeholder
    end
  end
=end
  
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
    AccountMailer.invite_user( invitee, inviter, self ).deliver
  end

  # TODO: Pull indexing into Entity; the only difference between Entity derivatives is
  # the fragments collection.
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
      ["Profile", "Overview"] => project_profile.overview,
      ["Profile", "People"] => project_profile.people,
      ["Profile", "Sponsors"] => project_profile.sponsors,

      # activities
      ["Activities", "Current Directions"] => project_profile.current_directions,
      ["Activities", "Outcomes"] => project_profile.outcomes,
      ["Activities", "History"] => project_profile.history,

      # services
      ["Services", "Data"] => project_profile.data,
      ["Services", "Tools"] => project_profile.tools,
      ["Services", "Training"] => project_profile.training,
      ["Services", "Events"] => project_profile.events,
      ["Services", "Opportunities"] => project_profile.opportunities,
      ["Services", "Other"] => project_profile.other,
    }

    aggregated_facets_map = {}
    ProfileTagCombiner::TAG_FIELDS.each do |tag|
      # See if this profile has any relevant tags in each field.
      tag_values = self.project_profile.send("#{tag.to_s.singularize}_list")

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
    # remove entity
    solr.remove_document(solr_entity_id())
    
    # profile
    solr.remove_document( solr_fragment_id( "Profile", "Name" ) )
    solr.remove_document( solr_fragment_id( "Profile", "Overview" ) )
    solr.remove_document( solr_fragment_id( "Profile", "People" ) )
    solr.remove_document( solr_fragment_id( "Profile", "Sponsors" ) )

    # activities
    solr.remove_document( solr_fragment_id( "Activities", "Current Directions" ) )
    solr.remove_document( solr_fragment_id( "Activities", "Outcomes" ) )
    solr.remove_document( solr_fragment_id( "Activities", "History" ) )
    
    # interests
    solr.remove_document( solr_fragment_id( "Interests", "Technologies" ) )
    solr.remove_document( solr_fragment_id( "Interests", "Time Periods of Interest" ) )
    solr.remove_document( solr_fragment_id( "Interests", "Places of Interest" ) )
    
    # services
    solr.remove_document( solr_fragment_id( "Services", "Data" ) )
    solr.remove_document( solr_fragment_id( "Services", "Tools" ) )
    solr.remove_document( solr_fragment_id( "Services", "Training" ) )
    solr.remove_document( solr_fragment_id( "Services", "Events" ) )
    solr.remove_document( solr_fragment_id( "Services", "Opportunities" ) )
    solr.remove_document( solr_fragment_id( "Services", "Other" ) )
    
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