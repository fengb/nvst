class UserOwnershipPresenter
  def initialize(user)
    @user_units_matcher = BestMatchHash.sum(user.ownerships.map{|c| [c.date, c.units]})
    @total_units_matcher = BestMatchHash.sum(Ownership.all.map{|c| [c.date, c.units]})
  end

  def percent_at(date)
    @user_units_matcher[date] / @total_units_matcher[date]
  end
end
