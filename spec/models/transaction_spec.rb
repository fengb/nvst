require 'spec_helper'

describe Transaction do
  describe '#adjusted_price' do
    subject { FactoryGirl.create(:transaction) }

    it '== #price when no adjustments' do
      expect(subject.adjusted_price).to eq(subject.price)
    end

    it '== #price when adjustment in the future' do
      adjustment = subject.adjustments.create!(date: Date.today + 1, ratio: 0.5)
      expect(subject.adjusted_price).to eq(subject.price)
    end

    it '== #price * adjustment#ratio on adjustment#date' do
      adjustment = subject.adjustments.create!(date: '2014-01-01', ratio: 0.5)
      expected = subject.price * adjustment.ratio
      expect(subject.adjusted_price(on: adjustment.date)).to eq(expected)
    end
  end
end
