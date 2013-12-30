require 'spec_helper'


describe Investment do
  describe 'many prices' do
    let(:investment) { Investment.create! }

    before do
      FactoryGirl.create(:investment_price, date: Date.today-0, investment: investment, high:  500, low: 400, close: 400)
      FactoryGirl.create(:investment_price, date: Date.today-180, investment: investment, high: 1000, low: 800, close: 900)
      FactoryGirl.create(:investment_price, date: Date.today-360, investment: investment, high:  400, low: 100, close: 200)
    end

    describe '#year_high' do
      it 'returns the high for the year' do
        expect(investment.year_high).to eq(1000)
      end
    end

    describe '#year_low' do
      it 'returns the low for the year' do
        expect(investment.year_low).to eq(100)
      end
    end

    describe '#current_price' do
      it 'returns the latest close' do
        expect(investment.current_price).to eq(400)
      end
    end

    describe '#price_matcher' do
      it 'returns the exact close price' do
        expect(investment.price_matcher[Date.today    ]).to eq(400)
        expect(investment.price_matcher[Date.today-180]).to eq(900)
        expect(investment.price_matcher[Date.today-360]).to eq(200)
      end

      it 'returns the last used close price when match not found' do
        expect(investment.price_matcher[Date.today-1  ]).to eq(900)
        expect(investment.price_matcher[Date.today-181]).to eq(200)
      end
    end
  end
end
