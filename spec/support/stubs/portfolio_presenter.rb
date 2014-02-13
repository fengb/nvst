class PortfolioPresenter::Stub
  def initialize(data)
    @values = {}
    @principals = {}
    @cashflows = {}

    data.each do |entry|
      @values[entry[:date]] = entry[:value]
      @principals[entry[:date]] = entry[:principal]
      @cashflows[entry[:date]] = entry[:cashflow] unless entry[:cashflow].zero?
    end
    @start_date = data.map{|e| e[:date]}.min
  end

  def value_at(date)
    @values[date] || 0
  end

  def principal_at(date)
    @principals[date] || 0
  end

  def cashflow_at(date)
    @cashflows[date] || 0
  end

  def cashflows
    @cashflows
  end

  def start_date
    @start_date
  end
end
