class PortfolioPresenter::Stub
  def initialize(data)
    @values = {}
    @principals = {}
    @cashflows = {}

    data.each do |entry|
      @values[entry[:date]] = entry[:value]
      @principals[entry[:date]] = entry[:principal]
      @cashflows[entry[:date]] = entry[:cashflow]
    end
  end

  def value_at(date)
    @values[date]
  end

  def principal_at(date)
    @principals[date]
  end

  def cashflow_at(date)
    @cashflows[date]
  end
end
