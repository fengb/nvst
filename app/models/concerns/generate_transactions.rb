module GenerateTransactions
  extend ModelsIncluded

  def generate_transactions!
    return if transactions.count > 0

    ActiveRecord::Base.transaction do
      raw_transactions_data.each do |data|
        transactions = GenerateTransactions.transact!(data)
        self.transactions.concat(transactions)
      end
    end

    self.transactions
  end

  class << self
    def transact!(data)
      if data[:adjustment] && data[:adjustment] != 1
        adjustment = Adjustment.new(date: data[:date],
                                    ratio: data[:adjustment])
      end

      if corresponding = Lot.corresponding(data)
        transaction = corresponding.transactions.build(data.except(:investment, :adjustment))
        transaction.adjustments << adjustment if adjustment.present?
        return [transaction]
      end

      shared_data = data.slice(:date, :price)
      shared_data[:adjustments] = [adjustment] if adjustment.present?
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
      lot = Lot.new(investment: investment,
                    open_date:  data[:date],
                    open_price: data[:price])
      transactions << Transaction.create!(shared_data.merge lot: lot,
                                                            shares: remaining_shares)
      transactions
    end

    def outstanding_lots(investment, new_shares)
      # Buy shares fill -outstanding, sell shares fill +outstanding
      direction = new_shares > 0 ? '-' : '+'
      LotStrategies.highest_cost_first(investment, direction)
    end

    class LotStrategies
      class << self
        def fifo(investment, direction)
          Lot.outstanding(direction).where(investment: investment)
                                    .order('open_date, id')
        end

        def highest_cost_first(investment, direction)
          Lot.outstanding(direction).where(investment: investment)
                                    .order('open_price DESC, open_date, id')
        end
      end
    end
  end
end
