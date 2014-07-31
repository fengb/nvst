require 'spec_helper'


describe Investment do
  describe 'many prices' do
    subject { Investment.create! }

    before do
      FactoryGirl.create(:investment_historical_price, date: Date.today-0,   investment: subject, high:  500, low: 400, close: 400)
      FactoryGirl.create(:investment_historical_price, date: Date.today-180, investment: subject, high: 1000, low: 800, close: 900)
      FactoryGirl.create(:investment_historical_price, date: Date.today-360, investment: subject, high:  400, low: 100, close: 200)
    end

    describe '#year_high' do
      it 'returns the high for the year' do
        expect(subject.year_high).to eq(1000)
      end
    end

    describe '#year_low' do
      it 'returns the low for the year' do
        expect(subject.year_low).to eq(100)
      end
    end

    describe '#current_price' do
      it 'returns the latest close' do
        expect(subject.current_price).to eq(400)
      end
    end

    describe '#price_matcher' do
      it 'returns the exact close price' do
        expect(subject.price_matcher[Date.today    ]).to eq(400)
        expect(subject.price_matcher[Date.today-180]).to eq(900)
        expect(subject.price_matcher[Date.today-360]).to eq(200)
      end

      it 'returns the last used close price when match not found' do
        expect(subject.price_matcher[Date.today-1  ]).to eq(900)
        expect(subject.price_matcher[Date.today-181]).to eq(200)
      end

      context 'start date' do
        it 'cuts off at the start date' do
          matcher = subject.price_matcher(Date.today - 180)
          expect(matcher[Date.today-180]).to eq(900)
          expect(matcher[Date.today-181]).to be(nil)
        end

        it 'cuts off at the closest available start date' do
          matcher = subject.price_matcher(Date.today - 179)
          expect(matcher[Date.today-180]).to eq(900)
          expect(matcher[Date.today-181]).to be(nil)
        end
      end
    end
  end

  describe Investment::Cash do
    it 'has prices of 1' do
      expect(subject.current_price).to eql(1)
      expect(subject.year_high).to eql(1)
      expect(subject.year_low).to eql(1)
    end

    it 'has super awesome price_matcher' do
      matcher = subject.price_matcher(Date.today)
      expect(matcher[Date.today         ]).to eql(1)
      expect(matcher[Date.today-1000    ]).to eql(1)
      expect(matcher[Date.today-10000000]).to eql(1)
    end
  end
end
