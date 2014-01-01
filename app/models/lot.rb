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

  def self.order_by_origination
    includes(:transactions).sort_by{|l| yield(l.transactions.first)}
  end

  def self.corresponding(search)
    Lot.includes(:transactions).find_each do |lot|
      return lot if lot.origination_date == search[:origination_date] and lot.origination_price == search[:origination_price]
    end
    nil
  end

  def origination_transactions
    transactions.select{|t| t.date == origination_date and t.price == origination_price}
  end

  def origination_date
    transactions.first.date
  end

  def origination_price
    transactions.first.price
  end

  def origination_value
    origination_transaction.value
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
    (current_price - origination_price) * outstanding_shares
  end

  def unrealized_gain_percent
    unrealized_gain / origination_value
  end
end
