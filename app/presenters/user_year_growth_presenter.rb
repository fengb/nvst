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

  def contribution_value(on: end_date)
    contributions(on: on).sum(&:amount)
  end

  def reinvestment_value(on: end_date)
    reinvestments(on: on).sum(&:amount)
  end

  def benchmark_value(on: end_date)
    shares = benchmark_shares_matcher[on]
    return 0 if shares == 0
    shares * benchmark_price_matcher[on]
  end

  def estimated_fee(on: end_date)
    [0, (gross_value(on: on) - benchmark_value(on: on)) / 2].max
  end

  def booked_fee(on: end_date)
    Transfer.fees.where(date: on, from_user: @user).sum(:amount)
  end

  def unbooked_fee(on: end_date)
    estimated_fee(on: end_date) - booked_fee(on: end_date)
  end

  def value(on: end_date)
    @ownership.user_percent(@user, on) * @portfolio.value_on(on)
  end

  def gross_value(on: end_date)
    value(on: on) + booked_fee(on: on)
  end

  def principal(on: end_date)
    contribution_value(on: on) + reinvestment_value(on: on) + starting_value
  end

  def gross_gains(on: end_date)
    gross_value(on: on) - principal(on: on)
  end

  def tentative_value(on: end_date)
    gross_value(on: on) - estimated_fee(on: on)
  end

  def starting_value
    value(on: start_date)
  end

  def tentative?(on: end_date)
    unbooked_fee(on: on).abs > 0.01
  end

  private
  def start_date
    @start_date ||= Date.new(@year, 1, 1)
  end

  def end_date
    @end_date ||= Date.new(@year, 12, 31)
  end

  def contributions(on: end_date)
    @contributions ||= @user.contributions.year(@year).to_a
    @contributions.select{|c| c.date <= on}
  end

  def reinvestments(on: end_date)
    @reinvestments ||= @user.reinvestments.year(@year).to_a
    @reinvestments.select{|c| c.date <= on}
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
