class InvestmentSplit < ActiveRecord::Base
  belongs_to :price, class_name: 'InvestmentPrice'
end
