# Generated
class InvestmentDividend < ActiveRecord::Base
  belongs_to :investment

  # FIXME: turn into a real relation
  def ex_previous_price
    InvestmentHistoricalPrice.find_by('investment_id = ? AND date < ?', investment_id, ex_date)
  end

  def percent
    amount / ex_previous_price.close
  end
end
