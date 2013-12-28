class Event < ActiveRecord::Base
  extend Enumerize
  belongs_to :src_investment, class_name: 'Investment'

  enumerize :reason, in: ['interest',
                          'tax',
                          'dividend - qualified',
                          'dividend - unqualified',
                          'dividend - tax-exempt',
                          'capital gains - short-term',
                          'capital gains - long-term']
end
