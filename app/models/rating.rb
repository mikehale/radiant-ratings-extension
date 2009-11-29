class Rating < ActiveRecord::Base
  belongs_to :page

  validates_presence_of     :rating, :page, :user_token
  validates_numericality_of :rating
  validates_uniqueness_of   :page_id, :scope => :user_token

  attr_readonly :page_id, :user_token
end
