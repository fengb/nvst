# Generated
class Position < ActiveRecord::Base
  belongs_to :investment
  has_many   :activities, ->{order('date')}

  validates :investment, presence: true

  scope :open, ->(during: Date.current, direction: nil){
    op = case direction.to_s
           when 'short' then '<'
           when 'long'  then '>'
           else              '!='
         end
    join_sql = SqlUtil.sanitize <<-SQL, during.to_date
      LEFT JOIN(SELECT position_id
                     , SUM(shares) AS outstanding_shares
                  FROM activities
                 WHERE date <= ?
                 GROUP BY position_id) t
             ON t.position_id=positions.id
    SQL
    joins(join_sql).where("t.outstanding_shares #{op} 0")
  }

  def opening_activity
    activities.opening.first
  end

  def long?
    opening(:shares) > 0
  end

  def short?
    opening(:shares) < 0
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

  def unrealized_principal
    (outstanding_shares * opening(:adjusted_price)).abs
  end

  def unrealized_gain_percent
    unrealized_gain / unrealized_principal
  end
end
