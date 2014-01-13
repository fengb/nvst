# Generated
class InvestmentSplit < ActiveRecord::Base
  belongs_to :investment

  def adjustment_to_past
    Rational(before) / after
  end
end
