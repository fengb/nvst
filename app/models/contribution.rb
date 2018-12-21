class Contribution < ApplicationRecord
  include GenerateActivitiesWaterfall
  include GenerateOwnerships
  include Scopes::Year

  belongs_to :user
  has_many :activities, as: :source
  has_many :ownerships, as: :source

  validates :user,   presence: true
  validates :date,   presence: true
  validates :amount, presence: true

  def self.as_transactions
    includes(:user).map do |contribution|
      Transaction.new(
        date: contribution.date,
        net_amount: contribution.amount,
        class_name: contribution.class.to_s,
        description: contribution.user.to_s,
      )
    end
  end

  def raw_activities_data
    [{investment: Investment::Cash.first,
      date:       date,
      shares:     amount,
      price:      1}]
  end

  def raw_ownerships_data
    [{user: user,
      date: date,
      units: ownership_units(on: date, amount: amount)}]
  end

  def cashflow_amount
    amount
  end
end
