module GenerateTransactions
  def generate_transactions!
    return if transactions.count > 0

    ActiveRecord::Base.transaction do
      to_raw_transactions_data.each do |data|
        transactions = GenerateTransactions.transact!(data)
        self.transactions.concat(transactions)
      end
    end

    self.transactions
  end

  class << self
    def transact!(data)
      if corresponding = Lot.corresponding(investment: data[:investment],
                                           origination_date: data[:date],
                                           origination_price: data[:price])
        return [corresponding.transactions.create!(data.except(:investment))]
      end

      shared_data = data.slice(:date, :price)
      investment = data[:investment]
      remaining_shares = data[:shares]

      transactions = []
      outstanding_lots(investment, remaining_shares).each do |lot|
        if lot.outstanding_shares.abs >= remaining_shares.abs
          transactions << lot.transactions.create!(shared_data.merge shares: remaining_shares)
          return transactions
        else
          remaining_shares += lot.outstanding_shares
          transactions << lot.transactions.create!(shared_data.merge shares: -lot.outstanding_shares)
        end
      end

      # Shares remaining with no lot
      lot = Lot.new(investment: investment)
      transactions << Transaction.create!(shared_data.merge lot: lot, shares: remaining_shares)
      transactions
    end

    def outstanding_lots(investment, new_shares)
      # Shares +new fill -outstanding, -new fill +outstanding
      direction = new_shares > 0 ? '-' : '+'
      Lot.outstanding(direction).where(investment: investment).order_by_origination do |trans|
        [-trans.price, trans.date, trans.id]
      end
    end
  end
end
