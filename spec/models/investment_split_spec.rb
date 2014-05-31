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

  describe '#generate_activity_for!' do
    let!(:activity) { FactoryGirl.create(:activity, shares: 6) }
    let(:lot)          { activity.lot }

    subject do
      InvestmentSplit.new(investment: lot.investment,
                          date: Date.today,
                          before: 1,
                          after: 2)
    end

    it 'adds an adjustment to opening activities' do
      subject.generate_activity_for!(lot)
      expect(activity.adjustments).to_not be_empty
    end

    it 'retains opening activity data' do
      old_data = activity.attributes.dup
      subject.generate_activity_for!(lot)
      expect_data(activity, old_data)
    end

    it 'creates a new activity with adjusted data' do
      new_activity = subject.generate_activity_for!(lot)
      expect_data(new_activity, investment:     lot.investment,
                                date:           subject.date,
                                tax_date:       activity.date,
                                adjusted_price: activity.adjusted_price)
    end

    it 'creates enough new shares' do
      new_activity = subject.generate_activity_for!(lot)
      expected_shares = activity.shares * subject.after / subject.before
      expect(new_activity.shares + activity.shares).to eq(expected_shares)
    end

    it 'has total new value == total old value' do
      old_value = activity.value
      new_activity = subject.generate_activity_for!(lot)

      new_value = new_activity.value + activity.value
      expect(new_value).to eq(old_value)
    end

    it 'only runs once' do
      subject.generate_activity_for!(lot)
      subject.generate_activity_for!(lot)

      expect(activity.adjustments.reload.size).to eq(1)
    end

    context 'with closing activities' do
      let!(:close_activity) do
        FactoryGirl.create(:activity, lot: lot,
                                      shares: -2,
                                      date: activity.date + 2)
      end

      it 'does not adjust closing activities' do
        subject.generate_activity_for!(lot)
        expect(close_activity.adjustments).to be_empty
      end

      it 'dies when lot has activities after split date' do
        # I don't see a good way to handle this automatically
        # (What does it mean to split a stock before a bunch of booked sales?)
        subject.date = close_activity.date
        expect {
          subject.generate_activity_for!(lot)
        }.to raise_error
      end
    end
  end
end
