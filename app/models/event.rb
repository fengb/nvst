class Event < ApplicationRecord
  include GenerateActivitiesWaterfall
  include Scopes::Year

  belongs_to :src_investment, class_name: 'Investment'
  has_and_belongs_to_many :activities

  validates :date,           presence: true
  validates :src_investment, presence: true
  validates :amount,         presence: true

  enum category: {
    'interest'                   => 'int',
    'interest - margin'          => 'inm',
    'tax'                        => 'tax',
    'dividend - ordinary'        => 'dvo',
    'dividend - qualified'       => 'dvq',
    'dividend - tax-exempt'      => 'dve',
    'capital gains - short-term' => 'cgs',
    'capital gains - long-term'  => 'cgl',
  }

  def raw_activities_data
    [{investment: Investment::Cash.first,
      date:       date,
      shares:     amount,
      price:      1}]
  end

  def net_amount
    amount
  end

  def description
    "#{category} for #{src_investment}"
  end
end
