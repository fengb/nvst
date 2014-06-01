module TaxDocs
  class ScheduleDPresenter
    def initialize(year)
      @year = year
    end

    def closing_activities
      @closing_activities ||= Activity.year(@year).tracked.closing.order(:date).to_a
    end
  end
end
