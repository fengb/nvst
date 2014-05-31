class LotSummaryPresenter
  attr_reader :lots

  def self.all
    lots = Lot.open.includes(:activities).sort_by{|l| l.opening(:date)}
    lots.group_by(&:investment).map{|inv, lots| self.new(lots)}
  end

  def initialize(lots)
    @lots = lots
  end

  def investment
    unique_by(&:investment)
  end

  def opening(attr, *args)
    unique_by{|l| l.opening(attr, *args)}
  end

  def outstanding_shares
    sum_by(&:outstanding_shares)
  end

  def current_price
    unique_by(&:current_price)
  end

  def current_value
    sum_by(&:current_value)
  end

  def unrealized_gain
    sum_by(&:unrealized_gain)
  end

  def unrealized_gain_percent
    unrealized_gain / sum_by{|lot| lot.outstanding_shares * lot.opening(:adjusted_price)}
  end

  private
  def unique_by(&block)
    elements = @lots.map(&block).uniq
    elements.size == 1 ? elements[0] : nil
  end

  def sum_by(&block)
    @lots.sum(&block)
  end
end
