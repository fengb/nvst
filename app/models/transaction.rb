# Generated
class Transaction < ActiveRecord::Base
  belongs_to :lot

  validates :lot, presence: true

  delegate :investment, to: :lot
end
