# Generated
class Lot < ActiveRecord::Base
  belongs_to :investment
  has_many   :transactions

  validates :investment, presence: true
end
