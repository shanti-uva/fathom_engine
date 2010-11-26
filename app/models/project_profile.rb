class ProjectProfile < ActiveRecord::Base
  
  belongs_to :project
  
  has_many :subject_links, :as => :subjectable, :dependent => :destroy
  has_many :subjects, :through => :subject_links
  
  #has_many :disciplines_project_profiles, :dependent=>:destroy
  #has_many :disciplines, :through => :disciplines_project_profiles
  
  acts_as_taggable_on *ProfileTagCombiner::TAG_FIELDS
  
  after_save {|pp|pp.project.save if pp.project}
  
  #validates_length_of :synopsis, :allow_blank => true, :maximum => 400, :message => " may be no longer than 400 characters.  Please try again."
  
  def project_attrs=(project_attributes={})
    project_attributes.each_pair do |k,v|
      project.send("#{k}=", v)
    end
  end
  
  def subject_ids_for_deletion=(subject_ids)
    subject_ids.each{|sid| subjects.delete(subjects.find(sid.to_i)) }
  end
  
  def field_set_blank?( field_set )
    case field_set
      when :activities then activities_blank?
      when :contact then contact_blank?
      else false
    end
  end
  
  def direct_contact_blank?
    [phone,fax,contact_email].all?{|v|v.blank?}
  end
  
  def mailing_address_blank?()
    [address_one,address_two,city,state,zipcode,country].all?{|v|v.blank?}
  end
  
  def contact_blank?
    direct_contact_blank? and mailing_address_blank? and notes.blank?
  end
  
  def activities_blank?() 
  	current_directions.blank? and outcomes.blank?
  end
  
  def interests_blank?
    state = [:disciplines, :general_interests, :time_periods_of_interest, :places_of_interest, :technologies_of_interest].detect do |tag_context|
      self.send(tag_context).size > 0
    end
    state == nil and interests.blank?
  end
  
  def services_blank?
    [data,tools,training,events,opportunities,other].all?{|a|a.blank?}
  end
  
end

# == Schema Info
# Schema version: 20100214201124
#
# Table name: project_profiles
#
#  id                 :integer(4)      not null, primary key
#  project_id         :integer(4)
#  address            :text
#  address_one        :string(255)
#  address_two        :string(255)
#  city               :string(255)
#  contact_email      :string(255)
#  country            :string(255)
#  current_directions :text
#  data               :text
#  events             :text
#  fax                :string(255)
#  history            :text
#  home_page          :string(255)
#  interests          :text
#  notes              :text
#  opportunities      :text
#  other              :text
#  outcomes           :text
#  overview           :text
#  people             :text
#  phone              :string(255)
#  sponsors           :text
#  state              :string(255)
#  tools              :text
#  training           :text
#  zipcode            :string(255)
#  created_at         :datetime
#  updated_at         :datetime