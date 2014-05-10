class GenerateSplitAdjustmentsJob
  def self.perform
    InvestmentSplit.each do |split|
      Lot.where(investment: split.investment).open(during: split.date).map do |existing_lot|
        perform_single(split, existing_lot)
      end
    end
  end

  def self.perform_single(split, existing_lot)
    adjustment = Adjustment.new(date: split.date,
                                numerator: split.before,
                                denominator: split.after,
                                reason: 'split')
    if existing_lot.transactions.where('date >= ?', adjustment.date).exists?
      raise 'Attempting to split but encountered future transactions'
    end

    ActiveRecord::Base.transaction do
      existing_lot.adjustments << adjustment
      existing_lot.transactions.open.each do |transaction|
        transaction.adjustments << adjustment
      end

      Lot.create!(investment: existing_lot.investment,
                  open_date:  split.date,
                  open_price: existing_lot.open_price).tap do |new_lot|
        total_shares = existing_lot.outstanding_shares * split.after / split.before
        new_transaction = Transaction.create!(lot: new_lot,
                                              date: split.date,
                                              price: existing_lot.open_price,
                                              shares: total_shares - existing_lot.outstanding_shares)

        new_transaction.adjustments = new_lot.adjustments = existing_lot.adjustments
      end
    end
  end
end
