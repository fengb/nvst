class Event < ActiveRecord::Base
  extend Enumerize
  belongs_to :src_investment, class_name: 'Investment'
  has_and_belongs_to_many :transactions

  enumerize :reason, in: ['interest',
                          'tax',
                          'dividend - qualified',
                          'dividend - unqualified',
                          'dividend - tax-exempt',
                          'capital gains - short-term',
                          'capital gains - long-term']

  def to_raw_transactions_data
    [{investment: Investment.cash,
      date:       date,
      shares:     amount,
      price:      1}]
  end
end
