class UserYearGrowthPresenter
  def self.for_user(user)
    user.active_years.map { |year| self.new(user, year) }
  end

  def self.for_year(year)
    User.all.map { |user| self.new(user, year) }
  end

  attr_reader :year, :user

  def initialize(user, year)
    @user = user
    @year = year
    @portfolio = PortfolioPresenter.all
    @ownership = OwnershipPresenter.all
  end

  def contributions(at: end_date)
    @contributions ||= @user.contributions.year(@year).to_a
    @contributions.select{|c| c.date <= at}
  end

  def gross_gains(at: end_date)
    gross_value(at: at) - contributions(at: at).sum(&:amount) - starting_value
  end

  def gross_value(at: end_date)
    @ownership.user_percent(@user, at) * @portfolio.value_at(at) + booked_fee(at: at)
  end

  def benchmark_value(at: end_date)
    shares = benchmark_shares_matcher[at]
    return 0 if shares == 0
    shares * benchmark_price_matcher[at]
  end

  def unbooked_fee(at: end_date)
    (gross_value(at: at) - benchmark_value(at: at)) / 2
  end

  def booked_fee(at: end_date)
    Transfer.fees.where(date: at, from_user: @user).sum(:amount)
  end

  def value(at: end_date)
    gross_value(at: at) - unbooked_fee(at: at)
  end

  def starting_value
    gross_value(at: start_date)
  end

  def closed?
    # FIXME
    booked_fee != 0
  end

  private
  def start_date
    @start_date ||= Date.new(@year, 1, 1)
  end

  def end_date
    @end_date ||= Date.new(@year, 12, 31)
  end

  def benchmark_shares_matcher
    @benchmark_shares_matcher ||= begin
      shares_raw = []
      if starting_value != 0
        shares_raw << [start_date, starting_value / benchmark_price_matcher[start_date]]
      end
      contributions.each do |contribution|
        shares_raw << [contribution.date, contribution.amount / benchmark_price_matcher[contribution.date]]
      end

      BestMatchHash.sum(shares_raw)
    end
  end

  def benchmark_price_matcher
    @benchmark_price_matcher ||= Investment.benchmark.price_matcher(start_date)
  end
end
