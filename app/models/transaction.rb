# Generated
class Transaction < ActiveRecord::Base
  belongs_to :lot

  validates :lot, presence: true

  delegate :investment, to: :lot

  def value
    shares * price
  end
end
