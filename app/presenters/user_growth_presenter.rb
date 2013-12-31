require 'best_match_hash'


class UserGrowthPresenter
  def initialize(user)
    @transactions_growth = TransactionsGrowthPresenter.all

    @contributions = user.contributions.order(:date)
    @units_matcher = BestMatchHash.sum(@contributions.map{|c| [c.date, c.units]})
  end

  def value_at(date)
    @units_matcher[date] / total_units * @transactions_growth.value_at(date)
  end

  private
  def total_units
    @total_units ||= Contribution.sum(:units)
  end
end
