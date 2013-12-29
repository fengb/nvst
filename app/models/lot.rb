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
  scope :order_by_purchase, ->(attr){includes(:transactions).sort_by{|l| l.transactions.first.send(attr)}}

  def outstanding_shares
    transactions.sum('shares')
  end
end
