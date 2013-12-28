class InvestmentDividend < ActiveRecord::Base
  belongs_to :price, class_name: 'InvestmentPrice'
end
