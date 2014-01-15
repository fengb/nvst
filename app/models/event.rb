class Event < ActiveRecord::Base
  extend Enumerize
  include GenerateTransactions
  include Scopes::Year

  belongs_to :src_investment, class_name: 'Investment'
  has_and_belongs_to_many :transactions

  enumerize :category, in: {'interest'                   => 'int',
                            'interest - margin'          => 'inm',
                            'tax'                        => 'tax',
                            'dividend - ordinary'        => 'dvo',
                            'dividend - qualified'       => 'dvq',
                            'dividend - tax-exempt'      => 'dve',
                            'capital gains - short-term' => 'cgs',
                            'capital gains - long-term'  => 'cgl'}

  def raw_transactions_data
    [{investment: Investment.cash,
      date:       date,
      shares:     amount,
      price:      1}]
  end
end
