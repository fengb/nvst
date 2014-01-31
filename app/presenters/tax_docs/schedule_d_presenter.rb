module TaxDocs
  class ScheduleDPresenter
    def initialize(year)
      @year = year
    end

    def users
      # FIXME: return active users
      User.all
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

    def expense_categories
      Expense.category.values
    end

    def expenses(category=nil)
      @expenses ||= Expense.year(@year).to_a
      category.nil? ? @expenses : @expenses.select{|e| e.category == category}
    end

    def events
      @events ||= begin
        events = Event.year(@year)
        Hash[Event.category.values.map{|c| [c, events.select{|e| e.category == c}]}]
      end
    end

    def close_transactions
      @close_transactions ||= Transaction.year(@year).tracked.close.order(:date).to_a
    end
  end
end
