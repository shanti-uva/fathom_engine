class TranslatedSource < ActiveRecord::Base
  validates_presence_of :title, :language_id, :source_id, :creator_id
  validates_uniqueness_of :language_id, :scope => :source_id
  belongs_to :language
  belongs_to :creator, :class_name => 'User', :foreign_key => 'creator_id'
  belongs_to :source
  has_and_belongs_to_many :authors, :class_name => 'Person', :join_table => 'authors_translated_sources', :association_foreign_key => 'author_id'
end


# == Schema Info
# Schema version: 20100214201124
#
# Table name: translated_sources
#
#  id          :integer(4)      not null, primary key
#  creator_id  :integer(4)      not null
#  language_id :integer(4)      not null
#  source_id   :integer(4)      not null
#  title       :text            not null, default("")
#  created_at  :datetime
#  updated_at  :datetime