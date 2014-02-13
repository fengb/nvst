class PublicPortfolioPresenter
  def initialize(portfolio, normalize_to)
    @portfolio = portfolio
    @normalize_to = normalize_to
  end

  def gross_value_at(date)
    pv = @portfolio.value_at(date)
    return 0 if pv.zero?
    @normalize_to * pv / adjusted_principal_at(date)
  end

  private
  def adjusted_principal_at(date)
    @adjustment_matcher ||= begin
      adjustments = @portfolio.cashflows.map do |date, amount|
        current_principal = @portfolio.principal_at(date)
        previous_principal = current_principal - amount
        if previous_principal.zero?
          adjusted_principal = amount
        else
          current_value = @portfolio.value_at(date)
          previous_value = current_value - amount
          adjusted_principal = current_value / (previous_value / previous_principal)
        end

        [date, adjusted_principal]
      end
      BestMatchHash.new(adjustments)
    end
    @adjustment_matcher[date]
  end
end
