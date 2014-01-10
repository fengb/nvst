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
    shares * (lot.open_price - price)
  end

  def open?
    date == lot.open_date && price == lot.open_price
  end
end
