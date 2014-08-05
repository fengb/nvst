class UserGrowthPresenter
  def initialize(user)
    @user = user
    @year_growths = {}
  end

  class YearGrowth
    def initialize(user, year)
      @user = user
      @year = year
      @portfolio = PortfolioPresenter.all
      @ownership = OwnershipPresenter.all
    end

    def gross_value_at(date)
      @ownership.user_percent(@user, date) * @portfolio.value_at(date) + booked_fee_at(date)
    end

    def benchmark_value_at(date)
      shares = benchmark_shares_matcher[date]
      return 0 if shares == 0
      shares * benchmark_price_matcher[date]
    end

    def unbooked_fee_at(date)
      (gross_value_at(date) - benchmark_value_at(date)) / 2
    end

    def booked_fee_at(date)
      Transfer.fees.where(date: date, from_user: @user).sum(:amount)
    end

    def value_at(date)
      gross_value_at(date) - unbooked_fee_at(date)
    end

    private
    def benchmark_shares_matcher
      @benchmark_shares_matcher ||= begin
        shares_raw = []
        starting_principal = gross_value_at(last_day_of_previous_year)
        if starting_principal != 0
          shares_raw << [last_day_of_previous_year, starting_principal / benchmark_price_matcher[last_day_of_previous_year]]
        end
        @user.contributions.year(@year).each do |contribution|
          shares_raw << [contribution.date, contribution.amount / benchmark_price_matcher[contribution.date]]
        end

        BestMatchHash.sum(shares_raw)
      end
    end

    def last_day_of_previous_year
      last_day_of_previous_year = Date.new(@year - 1, 12, 31)
    end

    def benchmark_price_matcher
      @benchmark_price_matcher ||= Investment.benchmark.price_matcher(last_day_of_previous_year)
    end
  end

  YearGrowth.instance_methods(false).each do |method|
    define_method method do |date|
      year_growth(date.year).send(method, date)
    end
  end

  private
  def year_growth(year)
    @year_growths[year] ||= YearGrowth.new(@user, year)
  end
end
