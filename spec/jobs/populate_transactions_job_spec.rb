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

    def expect_all(obj, data, data_extra={})
      data.merge(data_extra).each do |method, val|
        expect(obj.send(method)).to eq(val)
      end
    end

    def create_transaction!(options)
      lot = options[:lot] || Lot.new(investment: options.delete(:investment))
      Transaction.create!(options.merge lot: lot)
    end

    it 'creates new lot with single transaction when none exists' do
      transactions = job.transact!(data)
      expect(transactions.size).to eq(1)
      expect_all(transactions[0], data)
    end

    context 'existing lot' do
      let!(:existing) do
        create_transaction!(investment: investment,
                            date: Date.today - 2000,
                            shares: -10,
                            price: 5)
      end

      it 'ignores lots it cannot fill' do
        existing.update(shares: 10)
        transactions = job.transact!(data)
        expect(transactions.size).to eq(1)
        expect_all(transactions[0], data)
        expect(transactions[0].lot).to_not eq(existing.lot)
      end

      it 'ignores filled lots' do
        create_transaction!(lot: existing.lot,
                            date: Date.today - 1999,
                            shares: 10,
                            price: 4)

        transactions = job.transact!(data)
        expect(transactions.size).to eq(1)
        expect_all(transactions[0], data)
        expect(transactions[0].lot).to_not eq(existing.lot)
      end

      it 'fills when outstanding amount > new amount' do
        existing.update(shares: -300)

        transactions = job.transact!(data)
        expect(transactions.size).to eq(1)
        expect_all(transactions[0], data, lot: existing.lot)
      end

      it 'fills when outstanding amount == new amount' do
        existing.update(shares: -data[:shares])

        transactions = job.transact!(data)
        expect(transactions.size).to eq(1)
        expect_all(transactions[0], data, lot: existing.lot)
      end

      it 'fills up and creates new lot with remainder' do
        transactions = job.transact!(data)
        expect(transactions.size).to eq(2)
        expect_all(transactions[0], lot: existing.lot,
                                    date: data[:date],
                                    shares: -existing.shares,
                                    price: 1)
        expect(transactions[1].lot).to_not eq(existing.lot)
        expect_all(transactions[1], date: data[:date],
                                    shares: data[:shares] + existing.shares,
                                    price: 1)
      end
    end

    context 'existing lots' do
      let!(:existing) {[
        create_transaction!(investment: investment,
                            date: Date.today - 2000,
                            shares: -10,
                            price: 4),
        create_transaction!(investment: investment,
                            date: Date.today - 2000,
                            shares: -300,
                            price: 3),
      ]}

      it 'fills up first based on highest price' do
        transactions = job.transact!(data)
        expect(transactions.size).to eq(2)
        expect_all(transactions[0], lot: existing[0].lot,
                                    date: data[:date],
                                    shares: -existing[0].shares,
                                    price: data[:price])
        expect_all(transactions[1], lot: existing[1].lot,
                                    date: data[:date],
                                    shares: data[:shares] + existing[0].shares,
                                    price: data[:price])
      end

      it 'fills up all lots before creating new lot' do
        existing[1].update(shares: -20)

        transactions = job.transact!(data)
        expect(transactions.size).to eq(3)
        expect_all(transactions[0], lot: existing[0].lot,
                                    date: data[:date],
                                    shares: -existing[0].shares,
                                    price: data[:price])
        expect_all(transactions[1], lot: existing[1].lot,
                                    date: data[:date],
                                    shares: -existing[1].shares,
                                    price: data[:price])
        expect(transactions[2].lot).to_not eq(existing[0].lot)
        expect(transactions[2].lot).to_not eq(existing[1].lot)
        expect_all(transactions[2], date: data[:date],
                                    shares: data[:shares] + existing.map(&:shares).sum,
                                    price: data[:price])
      end
    end
  end
end
