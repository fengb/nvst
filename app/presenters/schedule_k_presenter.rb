class ScheduleKPresenter
  def initialize(year)
    @year = year
  end

  def users
    # FIXME: return active users
    User.all
  end

  def categories
    ['ordinary_income', *Event.category.values, 'short_term_capital_gain']
  end

  def value(category)
    if self.respond_to?(category)
      self.send(category)
    else
      events[category].sum(&:amount)
    end
  end

  def ordinary_income
    expenses.sum(:amount)
  end

  def short_term_capital_gain
    close_transactions.sum(&:realized_gain)
  end

  private
  def events
    @events ||= begin
      events = Event.year(@year)
      Hash[Event.category.values.map{|c| [c, events.select{|e| e.category == c}]}]
    end
  end

  def expenses
    @expenses ||= Expense.year(@year)
  end

  def close_transactions
    @close_transactions ||= Transaction.year(@year).tracked.close.order(:date).to_a
  end
end
