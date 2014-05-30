# Generated
class InvestmentSplit < ActiveRecord::Base
  belongs_to :investment
  belongs_to :transaction_adjustment

  default_scope ->{order(:date)}

  def price_adjustment
    Rational(before) / after
  end

  def price_adjust_up_to_date
    date - 1
  end

  def generate_transactions!
    Lot.where(investment: investment).open(during: date).map do |lot|
      self.generate_transaction_for!(lot)
    end
  end

  def transaction_adjustment!
    if self.transaction_adjustment.nil?
      self.create_transaction_adjustment(date: self.date,
                                         numerator: self.before,
                                         denominator:self.after,
                                         reason: 'split')
    else
      self.transaction_adjustment
    end
  end

  def generate_transaction_for!(lot)
    if lot.transactions.where('date >= ?', self.date).exists?
      raise 'Attempting to split but encountered future transactions'
    end

    ActiveRecord::Base.transaction do
      lot.transactions.opening.each do |transaction|
        transaction.adjustments << transaction_adjustment! unless transaction.adjustments.include?(transaction_adjustment!)
      end

      shares_adjustment = 1 / price_adjustment
      new_outstanding_shares = lot.outstanding_shares * shares_adjustment
      Transaction.create!(lot:         Lot.new(investment: lot.investment),
                          is_opening:  true,
                          date:        self.date,
                          tax_date:    lot.open_tax_date,
                          price:       lot.open_price,
                          shares:      new_outstanding_shares - lot.outstanding_shares,
                          adjustments: lot.open_adjustments)
    end
  end
end
