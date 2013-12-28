class InvestmentPrice < ActiveRecord::Base
  belongs_to :investment
  has_one    :dividend,   class_name: 'InvestmentDividend'
  has_one    :split,      class_name: 'InvestmentSplit'

  scope :year_range, ->(end_date=Date.today) { where(date: (end_date - 365)..end_date) }
end
