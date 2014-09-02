require 'spec_helper'

describe InvestmentHistoricalPrice do
  describe '.year_range' do
    let!(:prices) do
      { 0 => FactoryGirl.create(:investment_historical_price, date: Date.current),
        365 => FactoryGirl.create(:investment_historical_price, date: Date.current - 365),
        366 => FactoryGirl.create(:investment_historical_price, date: Date.current - 366)
      }
    end

    it 'includes investments from up to 1 year ago' do
      expect(InvestmentHistoricalPrice.year_range).to include(prices[0])
      expect(InvestmentHistoricalPrice.year_range).to include(prices[365])
    end

    it 'does not include from over 1 year ago' do
      expect(InvestmentHistoricalPrice.year_range).to_not include(prices[366])
    end
  end

  describe '#adjustment' do
    it 'defaults to 1' do
      expect(subject.adjustment).to eq(1)
    end
  end

  describe '#adjusted' do
    let(:adjustment) { 105 }
    subject { FactoryGirl.create(:investment_historical_price, adjustment: adjustment) }

    it 'adjusts number fields based on adjustment value' do
      expect(subject.adjusted(:close)).to eq(subject.close * adjustment)
      expect(subject.adjusted(:high)).to eq(subject.high * adjustment)
      expect(subject.adjusted(:low)).to eq(subject.low * adjustment)
    end
  end
end
