# Generated
class Position < ActiveRecord::Base
  belongs_to :investment
  has_many   :activities, ->{order('date')}

  validates :investment, presence: true

  scope :open, ->(during: Date.today, direction: nil){
    op = case direction.to_s
           when '+' then '>'
           when '-' then '<'
           else          '!='
         end
    outstanding_sql = sanitize_sql(['SELECT position_id
                                          , SUM(shares) AS outstanding_shares
                                       FROM activities
                                      WHERE date <= ?
                                      GROUP BY position_id',
                                    during.to_date])
    joins("LEFT JOIN (#{outstanding_sql}) t ON t.position_id=positions.id")
    .where("t.outstanding_shares #{op} 0", during)
  }

  def self.corresponding(options)
    activity = Activity.includes(:position).find_by(positions: {investment_id: options[:investment]},
                                                    tax_date:  options[:tax_date],
                                                    price:     options[:price])
    if activity && activity.shares.angle == options[:shares].angle &&
                   activity.adjustments[0].try(:ratio) == options[:adjustment]
      activity.position
    else
      nil
    end
  end

  def opening_activity
    activities.opening.first
  end

  def opening(attr, *args)
    opening_activity.send(attr, *args)
  end

  def outstanding_shares
    activities.sum('shares')
  end

  def current_price
    investment.current_price
  end

  def current_value
    current_price * outstanding_shares
  end

  def realized_gain
    activities.to_a.sum(&:realized_gain)
  end

  def unrealized_gain
    (current_price - opening(:adjusted_price)) * outstanding_shares
  end

  def unrealized_gain_percent
    unrealized_gain / (outstanding_shares * opening(:adjusted_price))
  end
end
