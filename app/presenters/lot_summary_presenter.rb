class LotSummaryPresenter
  def self.all
    Lot.outstanding.includes(:transactions).group_by(&:investment).map{|inv, lots| self.new(lots)}
  end

  def initialize(lots)
    @lots = lots
  end

  def investment
    unique_by(:investment)
  end

  def buy_date
    unique_by(:buy_date)
  end

  def buy_price
    unique_by(:buy_price)
  end

  def current_price
    unique_by(:current_price)
  end

  def buy_value
    sum_by(:buy_value)
  end

  def current_value
    sum_by(:current_value)
  end

  def unrealized_gain
    sum_by(:unrealized_gain)
  end

  def unrealized_gain_percent
    unrealized_gain / purchase_value
  end

  private
  def unique_by(name)
    elements = @lots.map(&name).uniq
    elements.size == 1 ? elements[0] : nil
  end

  def sum_by(name)
    @lots.map(&name).sum
  end
end
