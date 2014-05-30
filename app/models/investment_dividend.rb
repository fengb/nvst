# Generated
class InvestmentDividend < ActiveRecord::Base
  belongs_to :investment

  default_scope ->{order(:ex_date)}

  # FIXME: turn into a real relation
  def ex_previous_price
    InvestmentHistoricalPrice.where('investment_id = ? AND date < ?', investment_id, ex_date).last
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
