require 'spec_helper'


describe GenerateTransactionsJob do
  describe '.models_needing_processing' do
    it 'locates models with to_raw_transactions_data' do
      expect(GenerateTransactionsJob.send :models_needing_processing).to include(Contribution)
      expect(GenerateTransactionsJob.send :models_needing_processing).to include(Trade)
      expect(GenerateTransactionsJob.send :models_needing_processing).to include(Event)
      expect(GenerateTransactionsJob.send :models_needing_processing).to include(Expense)
    end
  end
end
