class Investment < ActiveRecord::Base
  has_many :prices, class_name: 'InvestmentPrice'
end
