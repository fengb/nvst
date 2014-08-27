class Trade < ActiveRecord::Base
  include GenerateActivitiesWaterfall

  belongs_to :cash,       class_name: 'Investment'
  belongs_to :investment, class_name: 'Investment'
  has_and_belongs_to_many :activities

  after_initialize do |record|
    record.cash ||= Investment::Cash.first
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

  def description
    "#{shares} shares of #{investment} @ #{price}"
  end
end
