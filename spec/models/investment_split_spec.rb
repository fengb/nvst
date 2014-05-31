require 'spec_helper'


describe InvestmentSplit do
  describe '#price_adjustment' do
    it 'compensates for expected drop in price' do
      # Date       Price   Split  Adjusted Price
      # Today       1.00     2:1            1.00
      # Yesterday   2.00                    1.00
      investment_split = InvestmentSplit.new(after: 2, before: 1)
      expect(investment_split.price_adjustment * 2).to eq(1)
    end
  end

  describe '#generate_transaction_for!' do
    let!(:transaction) { FactoryGirl.create(:transaction, shares: 6) }
    let(:lot)          { transaction.lot }

    subject do
      InvestmentSplit.new(investment: lot.investment,
                          date: Date.today,
                          before: 1,
                          after: 2)
    end

    it 'adds an adjustment to opening transactions' do
      subject.generate_transaction_for!(lot)
      expect(transaction.adjustments).to_not be_empty
    end

    it 'retains opening transaction data' do
      old_data = transaction.attributes.dup
      subject.generate_transaction_for!(lot)
      expect_data(transaction, old_data)
    end

    it 'creates a new transaction with adjusted data' do
      new_transaction = subject.generate_transaction_for!(lot)
      expect_data(new_transaction, investment:     lot.investment,
                                   date:           subject.date,
                                   tax_date:       transaction.date,
                                   adjusted_price: transaction.adjusted_price)
    end

    it 'creates enough new shares' do
      new_transaction = subject.generate_transaction_for!(lot)
      expected_shares = transaction.shares * subject.after / subject.before
      expect(new_transaction.shares + transaction.shares).to eq(expected_shares)
    end

    it 'has total new value == total old value' do
      old_value = transaction.value
      new_transaction = subject.generate_transaction_for!(lot)

      new_value = new_transaction.value + transaction.value
      expect(new_value).to eq(old_value)
    end

    it 'only runs once' do
      subject.generate_transaction_for!(lot)
      subject.generate_transaction_for!(lot)

      expect(transaction.adjustments.reload.size).to eq(1)
    end

    context 'with closing transactions' do
      let!(:close_transaction) do
        FactoryGirl.create(:transaction, lot: lot,
                                         shares: -2,
                                         date: transaction.date + 2)
      end

      it 'does not adjust closing transactions' do
        subject.generate_transaction_for!(lot)
        expect(close_transaction.adjustments).to be_empty
      end

      it 'dies when lot has transactions after split date' do
        # I don't see a good way to handle this automatically
        # (What does it mean to split a stock before a bunch of booked sales?)
        subject.date = close_transaction.date
        expect {
          subject.generate_transaction_for!(lot)
        }.to raise_error
      end
    end
  end
end
