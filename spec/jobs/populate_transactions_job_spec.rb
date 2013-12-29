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
      expect_all(transactions[0], data)
    end

    context 'existing lot' do
      let(:lot) { Lot.new(investment: investment) }

      it 'fills when outstanding amount > new amount' do
        existing = Transaction.create!(lot: lot,
                                       date: Date.today - 2000,
                                       shares: -300,
                                       price: 2)

        transactions = job.transact!(data)
        expect(transactions.size).to eq(1)
        expect_all(transactions[0], data)
        expect(transactions[0].lot).to eq(lot)
      end

      it 'fills when outstanding amount == new amount' do
        existing = Transaction.create!(lot: lot,
                                       date: Date.today - 2000,
                                       shares: -data[:shares],
                                       price: 2)

        transactions = job.transact!(data)
        expect(transactions.size).to eq(1)
        expect_all(transactions[0], data)
        expect(transactions[0].lot).to eq(lot)
      end

      it 'fills up and creates new lot with remainder' do
        existing = Transaction.create!(lot: lot,
                                       date: Date.today - 2000,
                                       shares: -10,
                                       price: 4)

        transactions = job.transact!(data)
        expect(transactions.size).to eq(2)
        expect_all(transactions[0], lot: lot,
                                    date: data[:date],
                                    shares: existing.shares.abs,
                                    price: 1)
        expect(transactions[1].lot).to_not eq(lot)
        expect_all(transactions[1], date: data[:date],
                                    shares: data[:shares] + existing.shares,
                                    price: 1)
      end
    end
  end
end
