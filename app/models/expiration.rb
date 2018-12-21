class Expiration < ApplicationRecord
  include GenerateActivitiesWaterfall

  belongs_to :investment, class_name: 'Investment'
  has_many :activities, as: :source

  validates :investment, presence: true
  validates :date,       presence: true
  validates :shares,     presence: true

  def self.as_transactions
    includes(:investment).map do |expiration|
      Transaction.new(
        date: expiration.date,
        net_amount: 0,
        class_name: expiration.class.to_s,
        description: "#{expiration.shares} shares of #{expiration.investment}",
      )
    end
  end

  def raw_activities_data
    [{investment: investment,
      date:       date,
      shares:     shares,
      price:      0.0}]
  end
end
