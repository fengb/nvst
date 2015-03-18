module TaxDocs
  class ScheduleDPresenter
    def initialize(year)
      @year = year
    end

    def closing_activities
      @closing_activities ||= Activity.closing.tracked.year(@year).includes(position: [:activities, :investment]).order(:date).to_a
    end
  end
end
