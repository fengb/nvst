require 'rails_helper'


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
      it 'is full value' do
        expect(subject.ownership_units(on: Date.current)).to eq(1)
      end
    end

    context 'existing ownership which doubled in value' do
      let!(:existing) { FactoryGirl.create(:ownership, units: 50) }
      before do
        allow(subject).to receive(:ownership_portfolio) { double(value_on: 100, cashflow_on: 0) }
      end

      it 'is full value on the same day as existing' do
        expect(subject.ownership_units(on: existing.date, amount: 50)).to eq(50)
      end

      it 'is half value afterwards' do
        # Adding $50 worth of units should bring total ownership to $50
        # new value == 150
        # therefore, new units should = 1/3 ownership
        expect(subject.ownership_units(on: existing.date + 1, amount: 50)).to eq(25)
      end

      it 'is adjusted when no cashflows' do
        # Odd behavior when not actually adding cash
        # Adding $50 worth of units should bring total ownership to $50
        # new value still == 100
        # therefore, new units should = 1/2 ownership
        expect(subject.ownership_units(on: existing.date + 1, amount: 50, cashflow: false)).to eq(50)
      end
    end
  end
end
