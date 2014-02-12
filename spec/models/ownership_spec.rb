require 'spec_helper'

describe Ownership do
  describe '.total_at' do
    let!(:ownerships) do
      [ Ownership.create(date: '2013-01-01', units: 100),
        Ownership.create(date: '2013-01-02', units: 200),
        Ownership.create(date: '2013-01-03', units:  50)
      ]
    end

    it 'returns the total at a date' do
      expect(Ownership.total_at '2013-01-02').to eq(300)
    end
  end

  describe '.new_unit_per_amount_multiplier_at' do
    context 'no existing ownerships' do
      it 'is 1' do
        expect(Ownership.new_unit_per_amount_multiplier_at Date.today).to eq(1)
      end
    end

    context 'existing ownership on the same day' do
      let!(:existing) { FactoryGirl.create(:ownership, units: 100) }

      it 'is 1' do
        expect(Ownership.new_unit_per_amount_multiplier_at existing.date).to eq(1)
      end
    end

    context 'existing ownership in the past' do
      let!(:existing) { FactoryGirl.create(:ownership, units: 50) }

      it 'is total units / current total value * contribution amount' do
        TransactionsGrowthPresenter.stub(all: double(value_at: 100, cashflow_at: 0))

        # We contributed 50 in the past and it grew to 100.
        # New contributions should have 1/2 the unit value
        expect(Ownership.new_unit_per_amount_multiplier_at(existing.date + 1)).to eq(0.5)
      end
    end
  end
end
