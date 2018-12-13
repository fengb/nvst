# Generated
class ActivityAdjustment < ApplicationRecord
  belongs_to :source, polymorphic: true
  has_and_belongs_to_many :activities

  validates :date,        presence: true
  validates :numerator,   presence: true
  validates :denominator, presence: true

  enum reason: { fee: 'fee', split: 'split' }

  def self.ratio(on: Date.current)
    data = where('date <= ?', on).pluck(:numerator, :denominator)
    data.inject(1) do |acc, args|
      acc * Rational(*args)
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
