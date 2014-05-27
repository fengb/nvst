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
      if corresponding = Lot.corresponding(data)
        data = data.slice(:date, :price, :shares)
                   .merge(lot:         corresponding,
                          adjustments: corresponding.open_adjustments)

        return [Transaction.create!(data)]
      end

      if data[:adjustment] && data[:adjustment] != 1
        adjustment = TransactionAdjustment.new(date:   data[:date],
                                               ratio:  data[:adjustment],
                                               reason: 'fee')
      end

      shared_data = data.slice(:date, :price)
      shared_data[:adjustments] = [adjustment].compact
      investment = data[:investment]
      remaining_shares = data[:shares]

      transactions = []
      open_lots(investment, remaining_shares).each do |lot|
        if lot.outstanding_shares.abs >= remaining_shares.abs
          transactions << lot.transactions.create!(shared_data.merge shares: remaining_shares)
          return transactions
        else
          remaining_shares += lot.outstanding_shares
          transactions << lot.transactions.create!(shared_data.merge shares: -lot.outstanding_shares)
        end
      end

      # Shares remaining with no lot
      lot = Lot.new(investment:  investment)
      transactions << Transaction.create!(shared_data.merge lot: lot,
                                                            shares: remaining_shares,
                                                            is_opening: true)
      transactions
    end

    def open_lots(investment, new_shares)
      # Buy shares fill -outstanding, sell shares fill +outstanding
      direction = new_shares > 0 ? '-' : '+'
      LotStrategies.highest_cost_first(investment, direction)
    end

    class LotStrategies
      class << self
        def fifo(investment, direction)
          Lot.open(direction: direction).where(investment: investment)
                                        .sort_by{|l| [l.open_date, l.id]}
        end

        def highest_cost_first(investment, direction)
          Lot.open(direction: direction).where(investment: investment)
                                        .sort_by{|l| [-l.open_price, l.open_date, l.id]}
        end
      end
    end
  end
end
