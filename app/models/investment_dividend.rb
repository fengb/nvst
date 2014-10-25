# Generated
class InvestmentDividend < ActiveRecord::Base
  belongs_to :investment

  validates :ex_date, presence: true, uniqueness: {scope: :investment}

  default_scope ->{order(:ex_date)}

  def ex_previous_price
    investment.historical_prices.previous_of(ex_date)
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
