class Trade < ApplicationRecord
  include GenerateActivitiesWaterfall

  belongs_to :cash,       class_name: 'Investment'
  belongs_to :investment, class_name: 'Investment'
  has_many :activities, as: :source

  validates :date,       presence: true
  validates :cash,       presence: true
  validates :net_amount, presence: true
  validates :investment, presence: true
  validates :shares,     presence: true
  validates :price,      presence: true

  after_initialize do |record|
    if record.cash_id.nil?
      record.cash ||= Investment::Cash.default
    end
  end

  def self.as_transactions
    includes(:investment).map do |trade|
      Transaction.new(
        date: trade.date,
        net_amount: trade.net_amount,
        class_name: trade.class.to_s,
        description: "#{trade.shares} shares of #{trade.investment} @ #{trade.price}",
      )
    end
  end

  def raw_activities_data
    [{investment: cash,
      date:       date,
      shares:     net_amount,
      price:      1.0,
      adjustment: 1},
     {investment: investment,
      date:       date,
      shares:     shares,
      price:      price,
      adjustment: adjustment}]
  end

  def investment_value
    shares * price
  end

  def adjustment
    - net_amount.to_r / (shares.to_r * price.to_r)
  end

  def fee
    investment_value + net_amount
  end
end
