# Generated
class ActivityAdjustment < ActiveRecord::Base
  extend Enumerize

  has_and_belongs_to_many :activities

  enumerize :reason, in: %w[fee split]

  def self.ratio(on: Date.today)
    select{|adj| adj.date <= on}.map(&:ratio).inject(1, :*)
  end

  def ratio=(value)
    self.numerator = value.numerator
    self.denominator = value.denominator
  end

  def ratio
    Rational(numerator, denominator)
  end
end
