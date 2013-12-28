class InvestmentPrice < ActiveRecord::Base
  belongs_to :investment
  has_one    :dividend,   class_name: 'InvestmentDividend'
  has_one    :split,      class_name: 'InvestmentSplit'
end
