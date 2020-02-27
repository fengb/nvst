# Generated
class InvestmentSplit < ApplicationRecord
  class SplitError < RuntimeError
  end

  belongs_to :investment
  has_one :activity_adjustment, as: :source

  validates :date,   presence: true
  validates :before, presence: true
  validates :after,  presence: true

  def to_s
    "split #{after}:#{before}"
  end

  def shares_adjustment
    1 / price_adjustment
  end

  def price_adjustment
    Rational(before, after)
  end

  def price_adjust_up_to_date
    date - 1
  end

  def generate_activities!
    Position.where(investment: investment).open(during: date).map do |position|
      self.generate_activity_for!(position)
    end
  end

  def activity_adjustment!
    if self.activity_adjustment.nil?
      self.create_activity_adjustment(date:        self.date,
                                      numerator:   self.before,
                                      denominator: self.after,
                                      reason:      'split')
      self.save!
    end

    self.activity_adjustment
  end

  def generate_activity_for!(position)
    if position.opening_activity.adjustments.include?(activity_adjustment)
      return
    elsif position.activities.where('date >= ?', self.date).exists?
      raise SplitError.new('Attempting to split but encountered future activities')
    end

    ActiveRecord::Base.transaction do
      position.opening_activity.adjustments << activity_adjustment!

      new_outstanding_shares = position.outstanding_shares * shares_adjustment
      position.activities.create!(
        source:      self,
        is_opening:  true,
        date:        self.date,
        tax_date:    position.opening(:tax_date),
        price:       position.opening(:price),
        shares:      new_outstanding_shares - position.outstanding_shares,
        adjustments: position.opening(:adjustments)
      )
    end
  end
end
