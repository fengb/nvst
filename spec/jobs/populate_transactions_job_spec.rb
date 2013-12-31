require 'spec_helper'


describe PopulateTransactionsJob do
  describe '.models_needing_processing' do
    it 'locates models with to_raw_transactions_data' do
      expect(PopulateTransactionsJob.send :models_needing_processing).to include(Contribution)
      expect(PopulateTransactionsJob.send :models_needing_processing).to include(Trade)
      expect(PopulateTransactionsJob.send :models_needing_processing).to include(Event)
      expect(PopulateTransactionsJob.send :models_needing_processing).to include(Expense)
    end
  end
end
