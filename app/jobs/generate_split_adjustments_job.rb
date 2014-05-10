class GenerateSplitAdjustmentsJob
  def self.perform
    InvestmentSplit.each do |split|
      perform_single(split)
    end
  end

  def self.perform_single(split)
    adjustment = Adjustment.new(date: split.date,
                                numerator: split.before,
                                denominator: split.after,
                                reason: 'split')
    Lot.where(investment: split.investment).open(during: split.date).map do |old_lot|
      if old_lot.transactions.where('date >= ?', adjustment.date).exists?
        raise 'Attempting to split but encountered future transactions'
      end

      ActiveRecord::Base.transaction do
        old_lot.adjustments << adjustment
        old_lot.transactions.open.each do |transaction|
          transaction.adjustments << adjustment
        end

        Lot.create!(investment: old_lot.investment,
                    open_date:  split.date,
                    open_price: old_lot.open_price).tap do |new_lot|
          total_shares = old_lot.outstanding_shares * split.after / split.before
          new_transaction = Transaction.create!(lot: new_lot,
                                                date: split.date,
                                                price: old_lot.open_price,
                                                shares: total_shares - old_lot.outstanding_shares)

          new_transaction.adjustments = new_lot.adjustments = old_lot.adjustments
        end
      end
    end
  end
end
