require 'spec_helper'

describe InvestmentHistoricalPrice do
  describe '.year_range' do
    before do
      @prices = {
        0 => FactoryGirl.create(:investment_historical_price, date: Date.today),
        365 => FactoryGirl.create(:investment_historical_price, date: Date.today - 365),
        366 => FactoryGirl.create(:investment_historical_price, date: Date.today - 366)
      }
    end

    it 'includes investments from up to 1 year ago' do
      expect(InvestmentHistoricalPrice.year_range).to include(@prices[0])
      expect(InvestmentHistoricalPrice.year_range).to include(@prices[365])
    end

    it 'does not include from over 1 year ago' do
      expect(InvestmentHistoricalPrice.year_range).to_not include(@prices[366])
    end
  end

  describe '#adjusted' do
    let(:price) { FactoryGirl.create(:investment_historical_price) }

    it 'adjusts number fields based on adjustment value' do
      price.stub(adjustment: 100)
      expect(price.adjusted(:close)).to eq(price.close * 100)
      expect(price.adjusted(:high)).to eq(price.high * 100)
      expect(price.adjusted(:low)).to eq(price.low * 100)
    end
  end
end
