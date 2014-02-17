class OwnershipPresenter
  def self.all
    self.new(Ownership.all)
  end

  def initialize(ownerships)
    @ownerships = ownerships
    @user_matchers = {}
  end

  def user_percent(user, date)
    return 0 if total_units(date) == 0

    user_units(user, date) / total_units(date)
  end

  def user_units(user, date)
    @user_matchers[user] ||= BestMatchHash.sum(@ownerships.select{|o| o.user == user}.map{|o| [o.date, o.units]})
    @user_matchers[user][date]
  end

  def total_units(date)
    @total_matcher ||= BestMatchHash.sum(@ownerships.map{|o| [o.date, o.units]})
    @total_matcher[date]
  end
end
