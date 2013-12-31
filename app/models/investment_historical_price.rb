# Generated
class InvestmentHistoricalPrice < ActiveRecord::Base
  belongs_to :investment

  default_scope ->{order(:date)}

  scope :year_range, ->(end_date=Date.today) { where(date: (end_date - 365)..end_date) }

  def adjusted(attr)
    self[attr] * self.adjustment
  end
end
