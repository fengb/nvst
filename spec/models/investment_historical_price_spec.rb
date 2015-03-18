require 'rails_helper'

describe InvestmentHistoricalPrice do
  describe 'many prices' do
    let!(:db_prices) do
      {   0 => FactoryGirl.create(:investment_historical_price, date: Date.current,       close: 400, adjustment: 0.5),
        365 => FactoryGirl.create(:investment_historical_price, date: Date.current - 365, close: 900, adjustment: 0.5),
        366 => FactoryGirl.create(:investment_historical_price, date: Date.current - 366, close: 200, adjustment: 0.5)
      }
    end

    describe '.year_range' do
      it 'includes investments from up to 1 year ago' do
        expect(InvestmentHistoricalPrice.year_range).to include(db_prices[0])
        expect(InvestmentHistoricalPrice.year_range).to include(db_prices[365])
      end

      it 'does not include from over 1 year ago' do
        expect(InvestmentHistoricalPrice.year_range).to_not include(db_prices[366])
      end
    end

    describe '.start_from' do
      it 'cuts off at the start date' do
        match = InvestmentHistoricalPrice.start_from(Date.current - 365)
        expect(match).to contain_exactly(*db_prices.values_at(0, 365))
      end

      it 'cuts off at the closest available start date' do
        match = InvestmentHistoricalPrice.start_from(Date.current - 180)
        expect(match).to contain_exactly(*db_prices.values_at(0, 365))
      end
    end

    describe '.matcher' do
      subject { InvestmentHistoricalPrice.matcher }

      it 'returns the exact close price' do
        expect(subject[Date.current    ]).to eq(400)
        expect(subject[Date.current-365]).to eq(900)
        expect(subject[Date.current-366]).to eq(200)
      end

      it 'returns the last used close price when match not found' do
        expect(subject[Date.current-1  ]).to eq(900)
        expect(subject[Date.current-364]).to eq(900)
      end

      context 'with adjusted(:close) }' do
        subject { InvestmentHistoricalPrice.matcher{|p| p.adjusted(:close)} }

        it 'returns adjusted close' do
          expect(subject[Date.current    ]).to eq(200)
          expect(subject[Date.current-365]).to eq(450)
          expect(subject[Date.current-366]).to eq(100)
        end
      end
    end
  end

  describe '#adjustment' do
    it 'defaults to 1' do
      expect(subject.adjustment).to eq(1)
    end
  end

  describe '#adjusted' do
    let(:adjustment) { 250 }
    subject { FactoryGirl.create(:investment_historical_price, adjustment: adjustment) }

    it 'adjusts number fields based on adjustment value' do
      expect(subject.adjusted(:close)).to eq(subject.close * adjustment)
      expect(subject.adjusted(:high)).to eq(subject.high * adjustment)
      expect(subject.adjusted(:low)).to eq(subject.low * adjustment)
    end
  end
end
