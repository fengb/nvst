require 'spec_helper'


describe GenerateTransactions do
  describe '#generate_transactions!' do
    class TestClass < OpenStruct
      include GenerateTransactions
    end

    subject { TestClass.new(transactions: [], raw_transactions_data: []) }

    context 'already has transactions' do
      before { subject.transactions = [1] }

      it 'returns nil' do
        expect(subject.generate_transactions!).to be(nil)
      end

      it 'does absolutely nothing' do
        GenerateTransactions.should_not_receive(:transact!)
        subject.generate_transactions!
      end
    end

    it 'passes raw transaction data to GenerateTransactions.transact!' do
      subject.raw_transactions_data = [4, 2, 5]
      GenerateTransactions.should_receive(:transact!).with(4).and_return([4])
      GenerateTransactions.should_receive(:transact!).with(2).and_return([2])
      GenerateTransactions.should_receive(:transact!).with(5).and_return([5])

      subject.generate_transactions!
    end

    it 'adds GenerateTransactions.transact! returned values to transactions' do
      subject.raw_transactions_data = [:a, :z]
      GenerateTransactions.stub(transact!: [1, 2])

      subject.generate_transactions!
      expect(subject.transactions).to eq([1, 2, 1, 2])
    end
  end

  describe '.transact!' do
    let(:investment) { FactoryGirl.create(:investment) }
    let(:data)       { {investment: investment,
                        date:       Date.today - rand(1000),
                        shares:     BigDecimal(rand(100..200)),
                        price:      BigDecimal(1)} }

    def expect_data(obj, data, data_extra={})
      data.merge(data_extra).each do |method, val|
        expect(obj.send(method)).to eq(val)
      end
    end

    def create_transaction!(options)
      if options[:lot]
        Transaction.create!(options.merge lot: options[:lot])
      else
        lot = Lot.new(investment: options.delete(:investment))
        trans = Transaction.create!(options.merge lot: lot)
        lot.update!(open_date: trans.date,
                    open_price: trans.price)
        trans
      end
    end

    it 'creates new lot with single transaction when none exists' do
      transactions = GenerateTransactions.transact!(data)
      expect(transactions.size).to eq(1)
      expect_data(transactions[0], data)
    end

    context 'corresponding lot' do
      let(:existing) do
        create_transaction!(investment: investment,
                            date: data[:date],
                            shares: -10,
                            price: data[:price])
      end

      before { Lot.stub(corresponding: existing.lot) }

      it 'reuses the lot' do
        transactions = GenerateTransactions.transact!(data)
        expect(transactions.size).to eq(1)
        expect_data(transactions[0], data, lot: existing.lot)
      end
    end

    context 'existing lot with different open data' do
      let!(:existing) do
        create_transaction!(investment: investment,
                            date: Date.today - 2000,
                            shares: -10,
                            price: 5)
      end

      it 'ignores lots it cannot fill' do
        existing.update(shares: 10)
        transactions = GenerateTransactions.transact!(data)
        expect(transactions.size).to eq(1)
        expect_data(transactions[0], data)
        expect(transactions[0].lot).to_not eq(existing.lot)
      end

      it 'ignores filled lots' do
        create_transaction!(lot: existing.lot,
                            date: Date.today - 1999,
                            shares: 10,
                            price: 4)

        transactions = GenerateTransactions.transact!(data)
        expect(transactions.size).to eq(1)
        expect_data(transactions[0], data)
        expect(transactions[0].lot).to_not eq(existing.lot)
      end

      it 'fills when outstanding amount > new amount' do
        existing.update(shares: -300)

        transactions = GenerateTransactions.transact!(data)
        expect(transactions.size).to eq(1)
        expect_data(transactions[0], data, lot: existing.lot)
      end

      it 'fills when outstanding amount == new amount' do
        existing.update(shares: -data[:shares])

        transactions = GenerateTransactions.transact!(data)
        expect(transactions.size).to eq(1)
        expect_data(transactions[0], data, lot: existing.lot)
      end

      it 'fills up and creates new lot with remainder' do
        transactions = GenerateTransactions.transact!(data)
        expect(transactions.size).to eq(2)
        expect_data(transactions[0], lot: existing.lot,
                                     date: data[:date],
                                     shares: -existing.shares,
                                     price: 1)
        expect(transactions[1].lot).to_not eq(existing.lot)
        expect_data(transactions[1], date: data[:date],
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
        transactions = GenerateTransactions.transact!(data)
        expect(transactions.size).to eq(2)
        expect_data(transactions[0], lot: existing[0].lot,
                                     date: data[:date],
                                     shares: -existing[0].shares,
                                    price: data[:price])
        expect_data(transactions[1], lot: existing[1].lot,
                                     date: data[:date],
                                     shares: data[:shares] + existing[0].shares,
                                    price: data[:price])
      end

      it 'fills up all lots before creating new lot' do
        existing[1].update(shares: -20)

        transactions = GenerateTransactions.transact!(data)
        expect(transactions.size).to eq(3)
        expect_data(transactions[0], lot: existing[0].lot,
                                     date: data[:date],
                                     shares: -existing[0].shares,
                                     price: data[:price])
        expect_data(transactions[1], lot: existing[1].lot,
                                     date: data[:date],
                                     shares: -existing[1].shares,
                                     price: data[:price])
        expect(transactions[2].lot).to_not eq(existing[0].lot)
        expect(transactions[2].lot).to_not eq(existing[1].lot)
        expect_data(transactions[2], date: data[:date],
                                     shares: data[:shares] + existing.sum(&:shares),
                                     price: data[:price])
      end
    end

    describe 'adjustments' do
      it 'ignores adjustment if == nil' do
        data[:adjustment] = nil
        transactions = GenerateTransactions.transact!(data)
        expect(transactions[0].adjustments).to be_blank
      end

      it 'ignores adjustment if == 1' do
        data[:adjustment] = 1
        transactions = GenerateTransactions.transact!(data)
        expect(transactions[0].adjustments).to be_blank
      end

      it 'creates an adjustment for the transaction date' do
        data[:adjustment] = 0.5
        transactions = GenerateTransactions.transact!(data)
        expect(transactions[0].adjustments.size).to eq(1)
        expect_data(transactions[0].adjustments[0], date: data[:date],
                                                    ratio: data[:adjustment])
      end

      context 'transaction waterfall' do
        before do
          data[:adjustment] = 2
          create_transaction!(investment: investment,
                              date: data[:date] - 1,
                              shares: -10,
                              price: data[:price])
        end

        it 'uses the same adjustment for multiple transactions' do
          transactions = GenerateTransactions.transact!(data)

          expect(transactions.size).to be > 1
          transactions.each do |transaction|
            expect(transaction.adjustments).to eq([transactions[0].adjustments[0]])
          end
        end

        it 'does not set adjustment for existing lots' do
          transactions = GenerateTransactions.transact!(data)
          transactions[0...-1].each do |transaction|
            expect(transaction.lot.adjustments).to be_blank
          end
        end

        it 'sets adjustment for newly created lot' do
          transactions = GenerateTransactions.transact!(data)
          transaction = transactions.last
          expect(transaction.lot.adjustments).to eq(transaction.adjustments)
        end
      end
    end
  end
end
