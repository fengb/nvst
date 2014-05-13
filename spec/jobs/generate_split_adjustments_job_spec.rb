require 'spec_helper'

describe GenerateSplitAdjustmentsJob do
  describe '.perform' do
    let!(:transaction1) { FactoryGirl.create(:transaction, shares: 6) }
    let(:lot)           { transaction1.lot }
    let!(:transaction2) { FactoryGirl.create(:transaction, lot: lot,
                                                           shares: -2,
                                                           date: transaction1.date + 2) }
    let(:split)         { InvestmentSplit.new(investment: lot.investment,
                                              date: Date.today,
                                              before: 1,
                                              after: 2) }

    it 'dies when lot has transactions after split date' do
      # I don't see a good way to handle this automatically
      # (What does it mean to split a stock right before a bunch of booked sales?)
      split.date = transaction2.date
      expect {
        GenerateSplitAdjustmentsJob.perform_single(split, lot)
      }.to raise_error
    end

    it 'adds an adjustment to opening transactions' do
      GenerateSplitAdjustmentsJob.perform_single(split, lot)
      expect(transaction1.adjustments).to_not be_empty
    end

    it 'does not adjust closing transactions' do
      GenerateSplitAdjustmentsJob.perform_single(split, lot)
      expect(transaction2.adjustments).to be_empty
    end

    it 'creates a new lot with adjusted data' do
      new_lot = GenerateSplitAdjustmentsJob.perform_single(split, lot)
      expect(new_lot).to be_present
      expect_data(new_lot, investment:          lot.investment,
                           open_date:           split.date,
                           adjusted_open_price: lot.adjusted_open_price)
    end

    it 'creates a new transaction with adjusted data' do
      new_lot = GenerateSplitAdjustmentsJob.perform_single(split, lot)
      expect(new_lot.transactions.count).to eq(1)
      expect_data(new_lot.transactions[0], date:           split.date,
                                           adjusted_price: lot.adjusted_open_price)
    end

    it 'creates a lot such that new outstanding shares == old outstanding value / new adjusted open price - existing shares' do
      old_value = lot.outstanding_shares * lot.adjusted_open_price
      new_lot = GenerateSplitAdjustmentsJob.perform_single(split, lot)

      total_outstanding = lot.outstanding_shares + new_lot.outstanding_shares
      expect(new_lot.outstanding_shares).to eq(old_value / new_lot.adjusted_open_price - lot.outstanding_shares)
    end
  end
end
