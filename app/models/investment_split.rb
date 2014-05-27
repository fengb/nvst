# Generated
class InvestmentSplit < ActiveRecord::Base
  belongs_to :investment

  default_scope ->{order(:date)}

  def adjustment
    Rational(before) / after
  end

  def adjust_up_to_date
    date - 1
  end

  def generate_transactions!
    Lot.where(investment: investment).open(during: date).map do |lot|
      self.generate_transaction_for!(lot)
    end
  end

  def generate_transaction_for!(lot)
    adjustment = TransactionAdjustment.new(date: self.date,
                                           numerator: self.before,
                                           denominator: self.after,
                                           reason: 'split')
    if lot.transactions.where('date >= ?', adjustment.date).exists?
      raise 'Attempting to split but encountered future transactions'
    end

    ActiveRecord::Base.transaction do
      lot.transactions.opening.each do |transaction|
        transaction.adjustments << adjustment
      end

      total_shares = lot.outstanding_shares / self.adjustment
      Transaction.create!(lot:         Lot.new(investment: lot.investment),
                          is_opening:  true,
                          date:        self.date,
                          price:       lot.open_price,
                          shares:      total_shares - lot.outstanding_shares,
                          adjustments: lot.open_adjustments)
    end
  end
end
