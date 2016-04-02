class UserYearGrowthPresenter
  def self.for_user(user)
    portfolio = PortfolioPresenter.all
    ownership = OwnershipPresenter.all
    user.active_years.map { |year| self.new(user, year, portfolio, ownership) }
  end

  def self.for_year(year)
    portfolio = PortfolioPresenter.all
    ownership = OwnershipPresenter.all
    User.all.map { |user| self.new(user, year, portfolio, ownership) }
  end

  attr_reader :year, :user

  def initialize(user, year, portfolio = PortfolioPresenter.all, ownership = OwnershipPresenter.all)
    @user = user
    @year = year
    @portfolio = portfolio
    @ownership = ownership
  end

  def contribution_value(at: end_date)
    contributions(at: at).sum(&:amount)
  end

  def reinvestment_value(at: end_date)
    reinvestments(at: at).sum(&:amount)
  end

  def benchmark_value(at: end_date)
    shares = benchmark_shares_matcher[at]
    return 0 if shares == 0
    shares * benchmark_price_matcher[at]
  end

  def estimated_fee(at: end_date)
    [0, (gross_value(at: at) - benchmark_value(at: at)) / 2].max
  end

  def booked_fee(at: end_date)
    Transfer.fees.where(date: at, from_user: @user).sum(:amount)
  end

  def unbooked_fee(at: end_date)
    estimated_fee(at: end_date) - booked_fee(at: end_date)
  end

  def value(at: end_date)
    @ownership.user_percent(@user, at) * @portfolio.value_at(at)
  end

  def gross_value(at: end_date)
    value(at: at) + booked_fee(at: at)
  end

  def principal(at: end_date)
    contribution_value(at: at) + reinvestment_value(at: at) + starting_value
  end

  def gross_gains(at: end_date)
    gross_value(at: at) - principal(at: at)
  end

  def tentative_value(at: end_date)
    gross_value(at: at) - estimated_fee(at: at)
  end

  def starting_value
    value(at: start_date)
  end

  def tentative?(at: end_date)
    unbooked_fee(at: at).abs > 0.01
  end

  private
  def start_date
    @start_date ||= Date.new(@year, 1, 1)
  end

  def end_date
    @end_date ||= Date.new(@year, 12, 31)
  end

  def contributions(at: end_date)
    @contributions ||= @user.contributions.year(@year).to_a
    @contributions.select{|c| c.date <= at}
  end

  def reinvestments(at: end_date)
    @reinvestments ||= @user.reinvestments.year(@year).to_a
    @reinvestments.select{|c| c.date <= at}
  end

  def benchmark_shares_matcher
    @benchmark_shares_matcher ||= begin
      benchmark_shares = benchmark_values.map do |date, value|
        [date, value / benchmark_price_matcher[date]]
      end

      BestMatchHash.sum(benchmark_shares)
    end
  end

  def benchmark_values
    Hash.new(0).tap do |values|
      if starting_value != 0
        values[start_date] += starting_value
      end
      contributions.each do |contribution|
        values[contribution.date] += contribution.amount
      end
      reinvestments.each do |reinvestment|
        values[reinvestment.date] += reinvestment.amount
      end
    end
  end

  def benchmark_price_matcher
    @benchmark_price_matcher ||= begin
      prices = Investment.benchmark.historical_prices.start_from(start_date)
      prices.matcher{|p| p.adjusted(:close)}
    end
  end
end
