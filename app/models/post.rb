class Post < ActiveRecord::Base
  has_one :entity
  belongs_to :post_kind

  before_save :ensure_valid_expiration_date

  validates_presence_of :expiration_date
  validates_presence_of :post_kind_id
  validates_presence_of :subject, :body
  validates_presence_of :response_email

  # Returns true if the post's expiration date is before today's date.
  def expired?(d = self.expiration_date)
    return d < Date.current
  end

  # Ensure that posts can have an expiration date that wouldn
  def ensure_valid_expiration_date
    self.expiration_date = Date.current if self.expiration_date < Date.current
  end
end

# == Schema Info
# Schema version: 20100214201124
#
# Table name: posts
#
#  id                :integer(4)      not null, primary key
#  entity_id         :integer(4)
#  post_kind_id      :string(255)
#  sponsor_entity_id :integer(4)
#  body              :text
#  expiration_date   :datetime
#  post_category     :string(255)
#  response_email    :string(255)
#  subject           :string(255)
#  created_at        :datetime
#  updated_at        :datetime