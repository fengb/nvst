# Generated
class InvestmentSplit < ActiveRecord::Base
  belongs_to :investment
  belongs_to :activity_adjustment

  default_scope ->{order(:date)}

  def price_adjustment
    Rational(before) / after
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
      self.create_activity_adjustment(date: self.date,
                                      numerator: self.before,
                                      denominator:self.after,
                                      reason: 'split')
    else
      self.activity_adjustment
    end
  end

  def generate_activity_for!(position)
    if position.activities.where('date >= ?', self.date).exists?
      raise 'Attempting to split but encountered future activities'
    end

    ActiveRecord::Base.transaction do
      position.activities.opening.each do |activity|
        activity.adjustments << activity_adjustment! unless activity.adjustments.include?(activity_adjustment!)
      end

      shares_adjustment = 1 / price_adjustment
      new_outstanding_shares = position.outstanding_shares * shares_adjustment
      Activity.create!(position:    Position.new(investment: position.investment),
                       is_opening:  true,
                       date:        self.date,
                       tax_date:    position.opening(:tax_date),
                       price:       position.opening(:price),
                       shares:      new_outstanding_shares - position.outstanding_shares,
                       adjustments: position.opening(:adjustments))
    end
  end
end
