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

  def self.order_by_purchase
    includes(:transactions).sort_by{|l| yield(l.transactions.first)}
  end

  def self.corresponding(search)
    Lot.includes(:transactions).find_each do |lot|
      return lot if lot.purchase_date == search[:purchase_date] and lot.purchase_price == search[:purchase_price]
    end
    nil
  end

  def purchase_transaction
    transactions.first
  end

  def purchase_date
    purchase_transaction.date
  end

  def purchase_price
    purchase_transaction.price
  end

  def purchase_value
    purchase_transaction.value
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

  def unrealized_gain
    (current_price - purchase_price) * outstanding_shares
  end

  def unrealized_gain_percent
    unrealized_gain / purchase_value
  end
end
