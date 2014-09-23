# Generated
class Ownership < ActiveRecord::Base
  belongs_to :user

  validates :user,  presence: true
  validates :date,  presence: true
  validates :units, presence: true

  def self.total_at(date)
    where('date <= ?', date).sum(:units)
  end

  def self.new_unit_per_amount_multiplier_at(date)
    portfolio = PortfolioPresenter.all
    # Assume all cashflows are incurred at once on the same day
    total_value = portfolio.value_at(date) - portfolio.cashflow_at(date)
    return 1 if total_value == 0

    # Assume all unit movement are incurred at once on the same day
    Ownership.total_at(date - 1) / total_value
  end
end
