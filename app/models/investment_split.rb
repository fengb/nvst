# Generated
class InvestmentSplit < ActiveRecord::Base
  belongs_to :investment

  default_scope ->{order(:date)}

  def adjustment
    Rational(before) / after
  end

  def adjust_up_to_date
    date - 1
  end
end
