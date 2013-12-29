# Generated
class Lot < ActiveRecord::Base
  belongs_to :investment
  has_many   :transactions, ->{order('date')}

  validates :investment, presence: true

  scope :outstanding, ->{joins("LEFT JOIN (SELECT lot_id
                                                , SUM(shares) AS outstanding_shares
                                             FROM transactions
                                            GROUP BY lot_id) t
                                       ON t.lot_id=lots.id"
                         ).where('outstanding_shares != 0')}
  scope :order_by_purchase_date, ->{includes(:transactions).sort_by{|l| l.transactions.first.date}}

  def outstanding_shares
    transactions.sum('shares')
  end
end
