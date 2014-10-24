# Generated
class ActivityAdjustment < ActiveRecord::Base
  extend Enumerize

  has_and_belongs_to_many :activities

  validates :date,        presence: true
  validates :numerator,   presence: true
  validates :denominator, presence: true

  enumerize :reason, in: %w[fee split]

  def self.ratio(on: Date.current)
    data = where('date <= ?', on).pluck(:numerator, :denominator)
    data.inject(1) do |acc, (numerator, denominator)|
      acc * Rational(numerator, denominator)
    end
  end

  def ratio=(value)
    self.numerator = value.numerator
    self.denominator = value.denominator
  end

  def ratio
    Rational(numerator, denominator)
  end
end
