class Link < ActiveRecord::Base

  has_one :entity

  def self.clean_link( link )
    return nil if link == nil
    unless link.include?("javascript:")
      unless link.starts_with?('http://')
        return link.blank?() ? "" : "http://#{link}"
      else
        return link
      end
    else
      return ''
    end
  end

  def validate()
    self.url = Link.clean_link(self.url)
  end
  
end


# == Schema Info
# Schema version: 20100214201124
#
# Table name: links
#
#  id         :integer(4)      not null, primary key
#  entity_id  :integer(4)
#  label      :string(255)
#  url        :string(255)
#  created_at :datetime
#  updated_at :datetime