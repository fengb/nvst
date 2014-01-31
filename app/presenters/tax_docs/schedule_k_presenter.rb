module TaxDocs
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

    def value(category, user=nil)
      raw = if self.respond_to?(category)
              self.send(category)
            else
              events[category].map{|e| [e.date, e.amount]}
            end
      if user
        raw.sum{|e| user_percent(user, e.first)*e.last}
      else
        raw.sum(&:last)
      end
    end

    def ordinary_income
      expenses.map{|e| [e.date, -e.amount]}
    end

    def short_term_capital_gain
      close_transactions.map{|t| [t.date, t.realized_gain]}
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

    def user_percent(user, date)
      @ownership ||= OwnershipPresenter.all
      @ownership.user_percent(user, date)
    end
  end
end
