class YearSummaryPresenter
  def initialize(year)
    @year = year
  end

  def realized_gain
    transactions.map(&:realized_gain).sum
  end

  def interest
    events['interest']
  end

  def ordinary_dividends
    events['dividend - ordinary']
  end

  def qualified_dividends
    events['dividend - qualified']
  end

  def tax_exempt_dividends
    events['dividend - tax-exempt']
  end

  def expenses
    @expenses ||= Hash[Expense.year(@year).group_by(&:category)]
  end

  def close_transactions
    @close_transactions ||= transactions.select(&:close?)
  end

  private
  def transactions
    @transactions ||= Transaction.year(@year).includes(lot: :transactions)
  end

  def events
    @events ||= Hash[Event.year(@year).group_by(&:category)]
  end
end
