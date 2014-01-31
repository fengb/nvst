module TaxDocs
  class ScheduleDPresenter
    def initialize(year)
      @year = year
    end

    def close_transactions
      @close_transactions ||= Transaction.year(@year).tracked.close.order(:date).to_a
    end
  end
end
