class PopulateTransactionsJob
  class << self
    def generate
      self.new(objects_needing_transactions).run!
    end

    private
    def models_needing_processing
      [].tap do |ret|
        ActiveRecord::Base.connection.tables.each do |table|
          str = table.singularize.camelize
          begin
            klass = Object.const_get(str)
          rescue NameError
            next
          end

          ret << klass if klass.method_defined?(:to_raw_transactions_data)
        end
      end
    end

    def objects_needing_processing
      models_needing_processing.map do |model|
        table = model.table_name
        ids = model.select("#{table}.id").joins(:transactions).group("#{table}.id").having('COUNT(transactions.id) = 0')
        model.find(ids)
      end.flatten
    end
  end

  def initialize(objects)
    @objects = objects.sort_by(&:date)
  end

  def run!
    @objects.each do |object|
      next if object.transactions.count > 0

      object.to_raw_transaction_data.each do |transaction_data|
        transactions = transact!(transaction_data)
      end
    end
  end

  def transact!(transaction_data)
    investment = transaction_data.delete(:investment)
    remaining_shares = transaction_data[:shares]
    transactions = []
    outstanding_lots(investment, remaining_shares).each do |lot|
      if lot.outstanding_shares.abs >= remaining_shares.abs
        transactions << lot.transactions.create!(transaction_data.merge(shares: remaining_shares))
        return transactions
      else
        remaining_shares += lot.outstanding_shares
        transactions << lot.transactions.create!(transaction_data.merge(shares: -lot.outstanding_shares))
      end
    end

    # Still remaining with no lot
    transactions << Transaction.create!(transaction_data.merge(lot: Lot.new(investment: investment), shares: remaining_shares))
    transactions
  end

  def sign(number)
  end

  def outstanding_lots(investment, new_shares)
    # Shares +new fill -outstanding, -new fill +outstanding
    direction = new_shares > 0 ? '-' : '+'
    Lot.outstanding(direction).where(investment: investment).order_by_purchase(:price).reverse
  end
end
