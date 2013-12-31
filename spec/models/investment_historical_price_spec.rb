require 'spec_helper'

describe InvestmentHistoricalPrice do
  describe '.year_range' do
    let!(:prices) do
      { 0 => FactoryGirl.create(:investment_historical_price, date: Date.today),
        365 => FactoryGirl.create(:investment_historical_price, date: Date.today - 365),
        366 => FactoryGirl.create(:investment_historical_price, date: Date.today - 366)
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

  describe '#adjusted' do
    let(:price) { FactoryGirl.create(:investment_historical_price) }

    it 'adjusts number fields based on adjustment value' do
      price.stub(adjustment: 100)
      expect(price.adjusted(:close)).to eq(price.close * 100)
      expect(price.adjusted(:high)).to eq(price.high * 100)
      expect(price.adjusted(:low)).to eq(price.low * 100)
    end
  end

  describe '#adjustment' do
    let(:price) { FactoryGirl.create(:investment_historical_price, raw_adjustment: 40) }

    it 'is price.raw_adjustment / InvestmentHistoricalPrice.latest_raw_adjustment' do
      InvestmentHistoricalPrice.should_receive(:latest_raw_adjustment).with(price.investment).and_return(100)

      expect(price.adjustment).to eq(BigDecimal('0.4'))
    end
  end

  describe '.latest_raw_adjustment' do
    let(:investment) { FactoryGirl.create(:investment) }
    let!(:prices) do
      [ FactoryGirl.create(:investment_historical_price, investment: investment),
        FactoryGirl.create(:investment_historical_price, investment: investment),
        FactoryGirl.create(:investment_historical_price, investment: investment)
      ]
    end

    it 'is the latest raw adjustment value' do
      latest = InvestmentHistoricalPrice.latest_raw_adjustment(investment)
      expect(latest).to eq(prices.sort_by(&:date).last.reload.raw_adjustment)
    end
  end
end
