# Generated
class Lot < ActiveRecord::Base
  belongs_to :investment
  has_many   :transactions, ->{order('date')}

  has_and_belongs_to_many :adjustments

  validates :investment, presence: true

  scope :open, ->(during: Date.today, direction: nil){
    op = case direction.to_s
           when '+' then '>'
           when '-' then '<'
           else          '!='
         end
    outstanding_sql = sanitize_sql(['SELECT lot_id
                                          , SUM(shares) AS outstanding_shares
                                       FROM transactions
                                      WHERE date <= ?
                                      GROUP BY lot_id',
                                    during.to_date])
    joins("LEFT JOIN (#{outstanding_sql}) t ON t.lot_id=lots.id")
    .where("t.outstanding_shares #{op} 0", during)
  }

  def self.corresponding(options)
    transaction = Transaction.includes(:lot).find_by(lots: {investment_id: options[:investment]},
                                                     date: options[:date],
                                                     price: options[:price])
    if transaction && transaction.shares.angle == options[:shares].angle &&
                      transaction.adjustments[0].try(:ratio) == options[:adjustment]
      transaction.lot
    else
      nil
    end
  end

  def open_price
    transactions.opening.first.price
  end

  def adjusted_open_price(on: Date.today)
    transactions.opening.first.adjusted_price(on: on)
  end

  def open_date
    transactions.opening.first.date
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
