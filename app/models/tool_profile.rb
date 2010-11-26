class ToolProfile < ActiveRecord::Base
  
  belongs_to :tool
  
  has_many :subject_links, :as => :subjectable, :dependent => :destroy
  has_many :subjects, :through => :subject_links
  
  #type of tool integration from Kmaps
   belongs_to :tool_type, :class_name => 'Category'
  
  #has_many :disciplines_tool_profiles, :dependent=>:destroy
  #has_many :disciplines, :through => :disciplines_tool_profiles
  
  acts_as_taggable_on *ProfileTagCombiner::TAG_FIELDS
  
  after_save {|pp|pp.tool.save if pp.tool}
  
#  validates_length_of :synopsis, :allow_blank => true, :maximum => 400, :message => " may be no longer than 400 characters.  Please try again."
  
  def tool_attrs=(tool_attributes={})
    tool_attributes.each_pair do |k,v|
      tool.send("#{k}=", v)
    end
  end

  def to_s
    "#{tool_type.title}"
  end  
  
  def subject_ids_for_deletion=(subject_ids)
    subject_ids.each{|sid| subjects.delete(subjects.find(sid.to_i)) }
  end
  
  def field_set_blank?( field_set )
    case field_set
      when :description then description_blank?
      when :reviews then reviews_blank?
      when :technology then technology_blank?
      when :support then support_blank?
      else false
    end
  end
  
  def description_blank?()
    [features, version_history].all?{|v|v.blank?} and self.send(:languages).size == 0
  end
  
  def reviews_blank?
    false #reviews.empty? 
  end
  
  def technology_blank?
    [technical_details].all?{|v|v.blank?} and self.send(:technologies_of_interest).size == 0 and self.send(:developers).size == 0 and self.send(:producers).size == 0 
  end
  
  def support_blank?
    [support,developer_resources, mailing_list, discussion_forums, tutorials, tips, more_information].all?{|v|v.blank?}
  end
  
end

# == Schema Info
# Schema version: 20100214201124
#
# Table name: tool_profiles
#
#  id                  :integer(4)      not null, primary key
#  tool_id             :integer(4)
#  tool_type_id        :integer(4)
#  cost                :text
#  developer_resources :text
#  discussion_forums   :text
#  download_page       :string(255)
#  features            :text
#  home_page           :string(255)
#  license             :text
#  mailing_list        :text
#  more_information    :text
#  operating_system    :text
#  platform            :text
#  summary             :text
#  support             :text
#  system_requirements :text
#  technical_details   :text
#  tips                :text
#  tutorials           :text
#  version_history     :text
#  created_at          :datetime
#  updated_at          :datetime