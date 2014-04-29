class PublicPortfolioPresenter
  def self.all(normalize_to)
    self.new(PortfolioPresenter.all, normalize_to)
  end

  def initialize(portfolio, normalize_to)
    @portfolio = portfolio
    @normalize_to = normalize_to
  end

  def cache_key
    "public_portfolio_presenter/#{dates.last.to_s(:number)}"
  end

  def dates
    # FIXME: tap into portfolio instead
    benchmark_price_matcher.keys
  end

  def value_at(date)
    gross_value_at(date) - fee_at(date)
  end

  def gross_value_at(date)
    pv = @portfolio.value_at(date)
    return 0 if pv.zero?
    @normalize_to * pv / adjusted_principal_at(date)
  end

  def fee_at(date)
    [(gross_value_at(date) - benchmark_value_at(date)) / 2, 0].max
  end

  def benchmark_value_at(date)
    benchmark_shares * benchmark_price_matcher[date]
  end

  private
  def benchmark_shares
    @benchmark_shares ||= @normalize_to / benchmark_price_matcher[@portfolio.start_date]
  end

  def benchmark_price_matcher
    @benchmark_price_matcher ||= Investment.benchmark.price_matcher(@portfolio.start_date)
  end

  def adjusted_principal_at(date)
    @adjustment_matcher ||= begin
      previous_adjusted = 1
      adjustments = @portfolio.cashflows.map do |date, amount|
        current_principal = @portfolio.principal_at(date)
        previous_principal = current_principal - amount
        if previous_principal.zero?
          new_adjusted = amount
        else
          current_value = @portfolio.value_at(date)
          previous_value = current_value - amount
          #new_adjusted = previous_adjusted + (current_value - previous_value) / (previous_value / previous_adjusted)
          new_adjusted = previous_adjusted + (current_value - previous_value) * previous_adjusted / previous_value
        end
        previous_adjusted = new_adjusted

        [date, new_adjusted]
      end
      BestMatchHash.new(adjustments)
    end
    @adjustment_matcher[date]
  end
end
