class PortfolioPresenter
  def self.all
    self.new(activities: Activity.includes(position: :investment),
             cashflows:  Contribution.all + Expense.cashflow)
  end

  def initialize(activities: [],
                 cashflows:  [])
    @price_matchers = {}
    @shares_matchers = {}
    activities.group_by(&:investment).each do |inv, activities|
      @shares_matchers[inv] = BestMatchHash.sum(activities.map{|t| [t.date, t.shares]})
    end
    @principal_matcher = BestMatchHash.sum(cashflows.map{|c| [c.date, c.cashflow_amount]})
    @cashflow_amounts = {}
    cashflows.each do |cf|
      @cashflow_amounts[cf.date] ||= 0
      @cashflow_amounts[cf.date] += cf.cashflow_amount
    end
  end

  def start_date
    @cashflow_amounts.keys.first
  end

  def dates
    (@cashflow_amounts.keys | price_matcher(investments[1]).keys).sort
  end

  def value_at(date)
    investments.sum{|i| value_for(i, date)}
  end

  def principal_at(date)
    @principal_matcher[date]
  end

  def cashflow_at(date)
    @cashflow_amounts[date] || 0
  end

  def cashflows
    @cashflow_amounts
  end

  private
  def value_for(investment, date)
    shares = shares_for(investment, date)
    shares.zero? ? 0 : shares * price_for(investment, date)
  end

  def price_for(investment, date)
    price_matcher(investment)[date]
  end

  def shares_for(investment, date)
    @shares_matchers[investment][date]
  end

  def investments
    @shares_matchers.keys
  end

  def price_matcher(investment)
    @price_matchers[investment] ||= investment.historical_prices.start_from(start_date_for(investment)).matcher
  end

  def start_date_for(investment)
    @shares_matchers[investment].keys.first
  end
end
