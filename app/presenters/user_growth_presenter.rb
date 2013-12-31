require 'best_match_hash'


class UserGrowthPresenter
  def initialize(user)
    @transactions_growth = TransactionsGrowthPresenter.all

    @contributions = user.contributions.order(:date)
    @units_matcher = sum_matcher(@contributions.map{|c| [c.date, c.units]})
    @amount_matcher = sum_matcher(@contributions.map{|c| [c.date, c.amount]})
  end

  def value_at(date)
    @units_matcher[date] / total_units * @transactions_growth.value_at(date)
  end

  private
  def total_units
    @total_units ||= Contribution.sum(:units)
  end

  def sum_matcher(values)
    by_key = {}
    sum = 0
    values.each do |key, value|
      sum += value
      by_key[key] = sum
    end
    BestMatchHash.new(by_key)
  end
end
