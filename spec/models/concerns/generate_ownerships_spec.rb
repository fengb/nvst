require 'spec_helper'


describe GenerateOwnerships do
  class TestClass < OpenStruct
    include GenerateOwnerships
  end

  subject { TestClass.new(ownerships: [], raw_ownerships_data: []) }

  describe '#generate_ownerships!' do

    context 'already has ownerships' do
      before { subject.ownerships = [1] }

      it 'returns nil' do
        expect(subject.generate_ownerships!).to be(nil)
      end

      it 'does absolutely nothing' do
        expect(subject.ownerships).to_not receive(:create!)
        subject.generate_ownerships!
      end
    end
  end

  describe '#ownership_units' do
    context 'no existing ownerships' do
      it 'is 1' do
        expect(subject.ownership_units(at: Date.current)).to eq(1)
      end
    end

    context 'existing ownership on the same day' do
      let!(:existing) { FactoryGirl.create(:ownership, units: 100) }

      it 'is 1' do
        expect(subject.ownership_units(at: existing.date)).to eq(1)
      end
    end

    context 'existing ownership in the past' do
      let!(:existing) { FactoryGirl.create(:ownership, units: 50) }

      it 'is total units / current total value * contribution amount' do
        allow(subject).to receive_messages(ownership_portfolio: double(value_at: 100, cashflow_at: 0))

        # We contributed 50 in the past and it grew to 100.
        # New contributions should have 1/2 the unit value
        expect(subject.ownership_units(at: existing.date + 1)).to eq(0.5)
      end
    end
  end
end
