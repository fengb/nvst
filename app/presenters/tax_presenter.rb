class TaxPresenter
  def initialize(year)
    @year = year
  end

  def realized_gain
    transactions.map(&:realized_gain).sum
  end

  def interest
    @interest ||= event_by('int')
  end

  def dividends
    @dividends ||= event_by(%w[dvo dvq dve])
  end

  def expenses
    @expenses ||= Expense.where('extract(year from date) = ?', @year)
  end

  def close_transactions
    @close_transactions ||= transactions.select(&:close?)
  end

  private
  def transactions
    @transactions ||= Transaction.where('EXTRACT(year FROM date) = ?', @year).includes(lot: :transactions)
  end

  def event_by(*reasons)
    Event.where('EXTRACT(year FROM date) = ?', @year).where(reason: reasons)
  end
end
