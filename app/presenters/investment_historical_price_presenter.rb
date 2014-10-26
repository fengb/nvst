require 'delegate'

class InvestmentHistoricalPricePresenter < SimpleDelegator
  def initialize(price, others=[])
    # Excelsior!
    super price

    @others = others
  end

  def self.where(args)
    wrap_all(InvestmentHistoricalPrice.where(args))
  end

  def self.wrap_all(historical_prices)
    investment_id = historical_prices.first.investment_id
    dates = historical_prices.map(&:date)
    others = InvestmentDividend.where(investment_id: investment_id, ex_date: dates)
    others.concat InvestmentSplit.where(investment_id: investment_id, date: dates)
    others_grouped = others.group_by(&:date)

    historical_prices.map do |price|
      InvestmentHistoricalPricePresenter.new(price, others_grouped[price.date] || [])
    end
  end

  def misc
    @others.map(&:to_s).join(', ')
  end
end
