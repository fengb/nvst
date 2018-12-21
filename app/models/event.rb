class Event < ApplicationRecord
  include GenerateActivitiesWaterfall
  include Scopes::Year

  belongs_to :src_investment, class_name: 'Investment'
  has_many :activities, as: :source

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

  def self.as_transactions
    includes(:src_investment).map do |event|
      Transaction.new(
        date: event.date,
        net_amount: event.amount,
        class_name: event.class.to_s,
        description: "#{event.category} for #{event.src_investment}",
      )
    end
  end

  def raw_activities_data
    [{investment: Investment::Cash.first,
      date:       date,
      shares:     amount,
      price:      1}]
  end
end
