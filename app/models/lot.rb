# Generated
class Lot < ActiveRecord::Base
  belongs_to :investment
  has_many   :transactions, ->{order('date')} do
    def open
      select(&:open?)
    end
  end

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
    if lot && options[:shares].angle == lot.transactions.first.shares.angle
      lot
    else
      nil
    end
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
    (current_price - open_price) * outstanding_shares
  end

  def unrealized_gain_percent
    unrealized_gain / (outstanding_shares * open_price)
  end
end
