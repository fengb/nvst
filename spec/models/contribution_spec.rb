describe Contribution do
  describe '#calculate_units' do
    context 'no existing ownerships' do
      it 'is the amount' do
        c = FactoryGirl.create(:contribution, units: 101)
        expect(c.calculate_units).to eq(c.amount)
      end
    end

    context 'existing ownership on the same day' do
      let!(:ownership) { FactoryGirl.create(:ownership, units: 100) }

      it 'is the amount' do
        c = FactoryGirl.create(:contribution, date: ownership.date, amount: 42)
        expect(c.calculate_units).to eq(c.amount)
      end
    end

    context 'existing ownership in the past' do
      let!(:ownership) { FactoryGirl.create(:ownership, units: 50) }

      it 'is total units / current total value * contribution amount' do
        c = FactoryGirl.create(:contribution, date: ownership.date + 1, amount: 42)
        TransactionsGrowthPresenter.stub(all: double(value_at: 142))

        # We contributed 50 in the past and it grew to 100.
        # New contributions should have 1/2 the unit value
        expect(c.calculate_units).to eq(c.amount / 2)
      end
    end
  end
end
