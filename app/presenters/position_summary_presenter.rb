class PositionSummaryPresenter
  attr_reader :positions

  def self.all
    positions = Position.open.includes(:activities).sort_by{|l| l.opening(:date)}
    positions.group_by(&:investment).map{|inv, positions| self.new(positions)}
  end

  def initialize(positions)
    @positions = positions
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
    unrealized_gain / sum_by{|position| position.outstanding_shares * position.opening(:adjusted_price)}
  end

  private
  def unique_by(&block)
    elements = @positions.map(&block).uniq
    elements.size == 1 ? elements[0] : nil
  end

  def sum_by(&block)
    @positions.sum(&block)
  end
end
