class GenerateTransactionsJob
  class << self
    def perform
      objects_needing_processing.sort_by{|o| [o.date, o.created_at]}.each do |o|
        o.generate_transactions!
      end
    end

    private
    def objects_needing_processing
      GenerateTransactions.models_included.map(&:all).flatten
    end
  end
end
