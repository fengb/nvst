# Generated
class InvestmentDividend < ApplicationRecord
  belongs_to :investment

  validates :ex_date, presence: true
  validates :amount,  presence: true

  def to_s
    "dividend #{amount}"
  end

  def ex_previous_price
    investment.historical_prices.previous_of(ex_date)
  end

  def date
    ex_date
  end

  def percent
    amount / ex_previous_price.close
  end

  def price_adjustment
    1 - percent
  end

  def price_adjust_up_to_date
    ex_date - 1
  end
end
