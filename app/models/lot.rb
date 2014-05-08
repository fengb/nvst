# Generated
class Lot < ActiveRecord::Base
  belongs_to :investment
  has_many   :transactions, ->{order('date')}

  has_and_belongs_to_many :adjustments

  validates :investment, presence: true

  scope :outstanding, ->(direction=nil){
    op = case direction.to_s
           when '+' then '>'
           when '-' then '<'
           else          '!='
         end
    joins("LEFT JOIN (SELECT lot_id
                           , SUM(shares) AS outstanding_shares
                        FROM transactions
                       GROUP BY lot_id) t
                  ON t.lot_id=lots.id"
    ).where("t.outstanding_shares #{op} 0")
  }

  def self.corresponding(options)
    lot = Lot.find_by(investment: options[:investment],
                      open_date:  options[:date],
                      open_price: options[:price])
    if lot && lot.transactions[0].shares.angle == options[:shares].angle &&
              lot.adjustments[0].try(:ratio) == options[:adjustment]
      lot
    else
      nil
    end
  end

  def adjusted_open_price(on: Date.today)
    open_price * adjustments.ratio(on: on)
  end

  def outstanding_shares
    transactions.sum('shares')
  end

  def current_price
    investment.current_price
  end

  def current_value
    current_price * outstanding_shares
  end

  def realized_gain
    transactions.to_a.sum(&:realized_gain)
  end

  def unrealized_gain
    (current_price - adjusted_open_price) * outstanding_shares
  end

  def unrealized_gain_percent
    unrealized_gain / (outstanding_shares * adjusted_open_price)
  end
end
