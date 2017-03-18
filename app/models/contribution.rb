class Contribution < ApplicationRecord
  include GenerateActivitiesWaterfall
  include GenerateOwnerships
  include Scopes::Year

  belongs_to :user
  has_and_belongs_to_many :ownerships
  has_and_belongs_to_many :activities

  validates :user,   presence: true
  validates :date,   presence: true
  validates :amount, presence: true

  def raw_activities_data
    [{investment: Investment::Cash.first,
      date:       date,
      shares:     amount,
      price:      1}]
  end

  def raw_ownerships_data
    [{user: user,
      date: date,
      units: ownership_units(at: date, amount: amount)}]
  end

  def cashflow_amount
    amount
  end

  def net_amount
    amount
  end

  def description
    "#{user}"
  end
end
