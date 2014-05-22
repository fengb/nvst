require 'spec_helper'


describe InvestmentSplit do
  describe '#adjustment' do
    it 'compensates for expected drop in price' do
      # Date       Price   Split  Adjusted Price
      # Today       1.00     2:1            1.00
      # Yesterday   2.00                    1.00
      investment_split = InvestmentSplit.new(after: 2, before: 1)
      expect(investment_split.adjustment * 2).to eq(1)
    end
  end

  describe '#generate_transaction_for!' do
    let!(:transaction1) { FactoryGirl.create(:transaction, shares: 6) }
    let(:lot)           { transaction1.lot }
    let!(:transaction2) { FactoryGirl.create(:transaction, lot: lot,
                                                           shares: -2,
                                                           date: transaction1.date + 2) }
    subject do
      InvestmentSplit.new(investment: lot.investment,
                          date: Date.today,
                          before: 1,
                          after: 2)
    end

    it 'dies when lot has transactions after split date' do
      # I don't see a good way to handle this automatically
      # (What does it mean to split a stock before a bunch of booked sales?)
      subject.date = transaction2.date
      expect {
        subject.generate_transaction_for!(lot)
      }.to raise_error
    end

    it 'adds an adjustment to opening transactions' do
      subject.generate_transaction_for!(lot)
      expect(transaction1.adjustments).to_not be_empty
    end

    it 'does not adjust closing transactions' do
      subject.generate_transaction_for!(lot)
      expect(transaction2.adjustments).to be_empty
    end

    it 'creates a new transaction with adjusted data' do
      transaction = subject.generate_transaction_for!(lot)
      expect_data(transaction, investment:     lot.investment,
                               date:           subject.date,
                               adjusted_price: transaction.adjusted_price)
    end

    it 'creates a lot such that new shares == old outstanding value / new adjusted open price - existing shares' do
      old_value = lot.outstanding_shares * lot.adjusted_open_price
      new_transaction = subject.generate_transaction_for!(lot)

      expect(new_transaction.shares).to eq(old_value / new_transaction.adjusted_price - lot.outstanding_shares)
    end
  end
end
