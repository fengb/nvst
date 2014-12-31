class Expiration < ActiveRecord::Base
  include GenerateActivitiesWaterfall

  belongs_to :investment, class_name: 'Investment'
  has_and_belongs_to_many :activities

  validates :investment, presence: true
  validates :date,       presence: true
  validates :shares,     presence: true

  def raw_activities_data
    [{investment: investment,
      date:       date,
      shares:     shares,
      price:      0.0,
      adjustment: 1}]
  end

  def description
    "#{shares} shares of #{investment}"
  end
end
