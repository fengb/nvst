describe Contribution do
  describe '#calculate_units' do
    context 'no existing contributions' do
      it 'is the amount' do
        c = FactoryGirl.create(:contribution, amount: 101)
        expect(c.calculate_units).to eq(c.amount)
      end
    end

    context 'existing contribution on the same day' do
      let!(:existing) { FactoryGirl.create(:contribution) }

      it 'is the amount' do
        c = FactoryGirl.create(:contribution, date: existing.date, amount: 42)
        expect(c.calculate_units).to eq(c.amount)
      end
    end

    context 'existing contribution in the past' do
      let!(:existing) { FactoryGirl.create(:contribution, units: 50) }

      it 'is total units / current total value * contribution amount' do
        c = FactoryGirl.create(:contribution, date: existing.date + 1, amount: 42)
        TransactionsGrowthPresenter.stub(all: double(value_at: 100))

        # We contributed 50 in the past and it grew to 100.
        # New contributions should have 1/2 the unit value
        expect(c.calculate_units).to eq(c.amount / 2)
      end
    end
  end
end
