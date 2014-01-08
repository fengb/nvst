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
    @expenses ||= begin
      expenses = Expense.year(@year)
      Hash[Expense.category.values.map{|c| [c, expenses.select{|e| e.category == c}]}]
    end
  end

  def events
    @events ||= begin
      events = Event.year(@year)
      Hash[Event.category.values.map{|c| [c, events.select{|e| e.category == c}]}]
    end
  end

  def close_transactions
    @close_transactions ||= transactions.select(&:close?)
  end

  private
  def transactions
    @transactions ||= Transaction.year(@year).includes(lot: :transactions)
  end
end
