class Contribution < ActiveRecord::Base
  include GenerateActivitiesWaterfall
  include GenerateOwnerships
  include Scopes::Year

  belongs_to :user
  has_and_belongs_to_many :ownerships
  has_and_belongs_to_many :activities

  def raw_activities_data
    [{investment: Investment::Cash.first,
      date:       date,
      shares:     amount,
      price:      1}]
  end

  def raw_ownerships_data
    [{user: user,
      date: date,
      units: amount * Ownership.new_unit_per_amount_multiplier_at(date)}]
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
