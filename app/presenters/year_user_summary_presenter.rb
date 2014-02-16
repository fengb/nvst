class YearUserSummaryPresenter
  def initialize(year, user)
    @year = year
    @user = user
  end

  def starting_balance
    user_growth.value_at(start_date)
  end

  def contributions
    @contributions ||= Contribution.where(user: @user).year(@year).sum(:amount)
  end

  def gross_gains
    gross_value - contributions
  end

  def management_fee
    @management_fee ||= Fee.where(from_user: @user).year(@year).sum(:amount)
  end

  def ending_balance
    gross_value + management_fee
  end

  private
  def user_growth
    @user_growth ||= UserGrowthPresenter.new(@user)
  end

  def gross_value
    # FIXME: gross_value should ignore fees
    user_growth.gross_value_at(end_date) - management_fee
  end

  def start_date
    Date.new(@year.to_i, 1, 1)
  end

  def end_date
    Date.new(@year.to_i, 12, 31)
  end
end
