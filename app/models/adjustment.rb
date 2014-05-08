# Generated
class Adjustment < ActiveRecord::Base
  has_and_belongs_to_many :transactions

  def self.ratio(on: Date.today)
    select{|adj| adj.date <= on}.map(&:ratio).inject(1, :*)
  end

  def ratio=(value)
    value_r = value.to_r
    self.numerator = value_r.numerator
    self.denominator = value_r.denominator
  end

  def ratio
    Rational(numerator, denominator)
  end
end
