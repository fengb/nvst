class YearSummaryPresenter
  def initialize(year)
    @year = year
  end

  def realized_gain
    transactions.map(&:realized_gain).sum
  end

  def interest
    @interest ||= event_by('int')
  end

  def ordinary_dividends
    @ordinary_dividends ||= event_by('dvo')
  end

  def qualified_dividends
    @qualified_dividends ||= event_by('dvq')
  end

  def tax_exempt_dividends
    @tax_exempt_dividends ||= event_by('dve')
  end

  def expenses
    @expenses ||= Expense.year(@year)
  end

  def close_transactions
    @close_transactions ||= transactions.select(&:close?)
  end

  private
  def transactions
    @transactions ||= Transaction.year(@year).includes(lot: :transactions)
  end

  def event_by(reason)
    Event.year(@year).where(reason: reasons)
  end
end
