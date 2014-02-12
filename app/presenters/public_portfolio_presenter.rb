class PublicPortfolioPresenter
  def initialize(portfolio, normalize_to)
    @portfolio = portfolio
    @normalize_to = normalize_to
  end

  def gross_value_at(date)
    pv = @portfolio.value_at(date)
    return 0 if pv.zero?
    @normalize_to * pv / @portfolio.principal_at(date)
  end
end
