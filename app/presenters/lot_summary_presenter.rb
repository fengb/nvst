class LotSummaryPresenter
  attr_reader :lots

  def self.all
    Lot.outstanding.includes(:transactions).order(:open_date).group_by(&:investment).map{|inv, lots| self.new(lots)}
  end

  def initialize(lots)
    @lots = lots
  end

  def investment
    unique_by(:investment)
  end

  def open_date
    unique_by(:open_date)
  end

  def outstanding_shares
    sum_by(:outstanding_shares)
  end

  def open_price
    unique_by(:open_price)
  end

  def current_price
    unique_by(:current_price)
  end

  def current_value
    sum_by(:current_value)
  end

  def unrealized_gain
    sum_by(:unrealized_gain)
  end

  def unrealized_gain_percent
    unrealized_gain / lots.sum{|lot| lot.outstanding_shares * lot.open_price}
  end

  private
  def unique_by(name)
    elements = @lots.map(&name).uniq
    elements.size == 1 ? elements[0] : nil
  end

  def sum_by(name)
    @lots.sum(&name)
  end
end
