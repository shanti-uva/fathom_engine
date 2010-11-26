class PersonProfile < ActiveRecord::Base
  
  belongs_to :person
  
  # It seems these have been replaced by the "acts_as_taggable_on" below
  #has_many :disciplines_person_profiles, :dependent=>:destroy
  #has_many :disciplines, :through => :disciplines_person_profiles
  
  has_many :professional_profile_links, :dependent=>:destroy
  has_many :professional_profiles, :through => :professional_profile_links
  
  acts_as_taggable_on *ProfileTagCombiner::TAG_FIELDS
  
  has_many :line_items
  
  after_save {|pp|pp.person.save if pp.person}
  
  # 
  # Allow updating of person attributes using a Hash.
  # The hash keys get converted to "#{key}=" and are then
  # sent as method calls to the person association.
  # This allows a single PersonProfile form to update it's Person.
  # 
  def person_attrs=(person_attributes={})
    person_attributes.each_pair do |k,v|
      person.send("#{k}=", v)
    end
  end
  
  def validate 
    self.home_page = Link.clean_link(self.home_page)
    self.cv_link = Link.clean_link(self.cv_link)
  end
  
  def field_set_blank?( field )
    case field    
    when :activities then activities_blank?()
    when :interests then interests_blank?()
    when :works then works_blank?()
    when :background then background_blank?()
    when :contact then contact_blank?()
    else false
    end
  end
  
  def update_disciplines( params )
    if params['discipline']
      discipline_ids = params['discipline'].keys
    else
      discipline_ids = []
    end

    Discipline.find(:all).each { |discipline|
      if discipline_ids.include?(discipline.id.to_s)
        # associate this discipline with this profile
        disciplines.push( discipline ) unless disciplines.include?( discipline )
      else
        # disassociate this discipline with this profile
        disciplines.delete( discipline )
      end
    }
  end
  
  def update_professional_profiles( params )
    if params['professional_profile']
      professional_profile_ids = params['professional_profile'].keys
    else
      professional_profile_ids = []
    end
  
    ProfessionalProfile.find(:all).each { |professional_profile|
      if professional_profile_ids.include?(professional_profile.id.to_s)
        # associate this discipline with this profile
        professional_profiles.push( professional_profile ) unless professional_profiles.include?( professional_profile )
      else
        # disassociate this discipline with this profile
        professional_profiles.delete( professional_profile )
      end
    }
  end
  
  def address_blank?()
    address_one.blank? and address_two.blank? and city.blank? and country.blank?
  end
  
  def direct_contact_blank?()
		office_phone.blank? and cell_phone.blank? and other_contact.blank? and email.blank?
  end
  
  def activities_blank?()
    focus.blank? and goals.blank? and activities_overview.blank?
  end
  
  #
  def interests_blank?
    state = [:disciplines, :general_interests, :time_periods_of_interest, :places_of_interest, :technologies_of_interest].detect do |tag_context|
      self.send(tag_context).size > 0
    end
    state == nil and interests.blank?
  end
  
  def works_blank?() 
    works_overview.blank? and publications.blank? and websites.blank? and tools.blank? and miscellaneous.blank?
  end

  def background_blank?()
    line_items_of_kind(:affiliations, :credentials, :positions).blank? &&
      cv_link.blank? &&
      skills.blank? &&
      technologies_of_interest.blank?
  end

  def contact_blank?()
    direct_contact_blank? and address_blank?
  end

  # Returns all the line items of one or more specified kinds.
  # FUTURE: Ensure that users of PersonProfile are using line_items_of_kind, not using line_items magic
  # themselves.
  # FUTURE: Ensure that other profiles are doing the same thing.
  def line_items_of_kind(*kinds)
    return nil if kinds.nil?
    return nil if kinds.compact.empty?

    # Check to see if a particular LineItem matches the desired kind.
    line_items.select do |i|
      kinds.flatten.each do |k|
        break true if i.category == k.to_s
      end == true
    end
  end
end

# == Schema Info
# Schema version: 20100214201124
#
# Table name: person_profiles
#
#  id                   :integer(4)      not null, primary key
#  person_id            :integer(4)
#  activities_overview  :text
#  address_one          :string(255)
#  address_two          :string(255)
#  cell_phone           :string(255)
#  city                 :string(255)
#  country              :string(255)
#  cv_link              :string(255)
#  email                :string(255)
#  first_name           :string(255)
#  focus                :text
#  goals                :text
#  home_page            :string(255)
#  home_phone           :string(255)
#  interests            :text
#  last_name            :string(255)
#  middle_initial       :string(255)
#  miscellaneous        :text
#  notes                :text
#  office_phone         :string(255)
#  other_contact        :string(255)
#  other_contact_type   :string(255)
#  overview             :text
#  professional_profile :text
#  publications         :text
#  skills               :text
#  state                :string(255)
#  title                :string(255)
#  tools                :text
#  websites             :text
#  works_overview       :text
#  zipcode              :string(255)
#  created_at           :datetime
#  updated_at           :datetime