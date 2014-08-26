module TaxDocs
  class ScheduleKPresenter
    def initialize(year)
      @year = year
    end

    def users
      User.active_in(@year)
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
      closing_activities.map{|t| [t.date, t.realized_gain]}
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

    def closing_activities
      @closing_activities ||= Activity.year(@year).tracked.closing.order(:date).to_a
    end

    def user_percent(user, date)
      @ownership ||= OwnershipPresenter.all
      @ownership.user_percent(user, date)
    end
  end
end
