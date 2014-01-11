# Generated
class Lot < ActiveRecord::Base
  belongs_to :investment
  has_many   :transactions, ->{order('date')}

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

  def self.order_by_open
    includes(:transactions).sort_by{|l| yield(l.transactions.first)}
  end

  def open_transactions
    transactions.select(&:open?)
  end

  def open_value
    open_transactions.map(&:value).sum
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
    transactions.map(&:realized_gain).sum
  end

  def unrealized_gain
    (current_price - open_price) * outstanding_shares
  end

  def unrealized_gain_percent
    unrealized_gain / open_value
  end
end
