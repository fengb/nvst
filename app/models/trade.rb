class Trade < ActiveRecord::Base
  belongs_to :sell_investment, class_name: 'Investment'
  belongs_to :buy_investment,  class_name: 'Investment'
end
