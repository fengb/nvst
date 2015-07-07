require 'rails_helper'


describe InvestmentSplit do
  describe 'adjustments' do
    # Date       Price   Shares
    # Yesterday   2.00       50
    # Today       1.00      100
    subject { FactoryGirl.build(:investment_split, after: 2, before: 1) }

    specify '#price_adjustment compensates for drop in price' do
      expect(subject.price_adjustment * 2).to eq(1)
    end

    specify '#price_adjustment compensates for drop in price' do
      expect(subject.shares_adjustment * 50).to eq(100)
    end
  end

  describe '#generate_activity_for!' do
    let!(:activity) { FactoryGirl.create(:activity, shares: 6) }
    let(:position)  { activity.position }

    subject do
      InvestmentSplit.create(investment: position.investment,
                             date: Date.current,
                             before: 1,
                             after: 2)
    end

    it 'adds an adjustment to opening activities' do
      subject.generate_activity_for!(position)
      expect(activity.adjustments).to_not be_empty
    end

    it 'retains opening activity data' do
      old_data = activity.attributes.dup
      subject.generate_activity_for!(position)
      expect(activity).to have_attributes(old_data)
    end

    it 'creates a new activity with existing data' do
      new_activity = subject.generate_activity_for!(position)
      expect(new_activity).to have_attributes(investment:     position.investment,
                                              date:           subject.date,
                                              tax_date:       activity.date,
                                              position:       activity.position,
                                              adjusted_price: activity.adjusted_price)
    end

    it 'creates enough new shares' do
      new_activity = subject.generate_activity_for!(position)
      expected_shares = activity.shares * subject.after / subject.before
      expect(new_activity.shares + activity.shares).to eq(expected_shares)
    end

    it 'has total new value == total old value' do
      old_value = activity.value
      new_activity = subject.generate_activity_for!(position)

      new_value = new_activity.value + activity.value
      expect(new_value).to eq(old_value)
    end

    it 'only runs once' do
      subject.generate_activity_for!(position)
      subject.reload
      subject.generate_activity_for!(position)

      expect(activity.adjustments.reload.size).to eq(1)
    end

    context 'with closing activities' do
      let!(:close_activity) do
        FactoryGirl.create(:activity, position: position,
                                      shares: -2,
                                      date: activity.date + 2)
      end

      it 'does not adjust closing activities' do
        subject.generate_activity_for!(position)
        expect(close_activity.adjustments).to be_empty
      end

      it 'dies when position has activities after split date' do
        # I don't see a good way to handle this automatically
        # (What does it mean to split a stock before a bunch of booked sales?)
        subject.date = close_activity.date
        expect {
          subject.generate_activity_for!(position)
        }.to raise_error(InvestmentSplit::SplitError)
      end
    end
  end
end
