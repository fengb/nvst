# Generated
class Transaction < ActiveRecord::Base
  include Scopes::Year

  belongs_to :lot

  validates :lot, presence: true

  delegate :investment, to: :lot

  def value
    shares * price
  end

  def realized_gain
    shares * (lot.origination_price - price)
  end

  def origination?
    date == lot.origination_date && price == lot.origination_price
  end
end
