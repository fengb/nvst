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

  describe '#transact!' do
    let(:investment) { FactoryGirl.create(:investment) }
    let(:job)        { PopulateTransactionsJob.new([]) }
    let(:data)       { {investment: investment,
                        date:       Date.today - rand(1000),
                        shares:     BigDecimal(rand(100..200)),
                        price:      BigDecimal(1)} }

    def expect_all(obj, data)
      data.each do |method, val|
        expect(obj.send(method)).to eq(val)
      end
    end

    it 'creates new lot with single transaction when none exists' do
      transactions = job.transact!(data)
      expect(transactions.size).to eq(1)
      expect_all(transactions.first, data)
    end
  end
end
