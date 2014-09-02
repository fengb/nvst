require 'spec_helper'


describe Investment do
  describe 'many prices' do
    subject { Investment.create! }

    before do
      FactoryGirl.create(:investment_historical_price, date: Date.current-0,   investment: subject, high:  500, low: 400, close: 400)
      FactoryGirl.create(:investment_historical_price, date: Date.current-180, investment: subject, high: 1000, low: 800, close: 900)
      FactoryGirl.create(:investment_historical_price, date: Date.current-360, investment: subject, high:  400, low: 100, close: 200)
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
        expect(subject.price_matcher[Date.current    ]).to eq(400)
        expect(subject.price_matcher[Date.current-180]).to eq(900)
        expect(subject.price_matcher[Date.current-360]).to eq(200)
      end

      it 'returns the last used close price when match not found' do
        expect(subject.price_matcher[Date.current-1  ]).to eq(900)
        expect(subject.price_matcher[Date.current-181]).to eq(200)
      end

      context 'start date' do
        it 'cuts off at the start date' do
          matcher = subject.price_matcher(Date.current - 180)
          expect(matcher[Date.current-180]).to eq(900)
          expect(matcher[Date.current-181]).to be(nil)
        end

        it 'cuts off at the closest available start date' do
          matcher = subject.price_matcher(Date.current - 179)
          expect(matcher[Date.current-180]).to eq(900)
          expect(matcher[Date.current-181]).to be(nil)
        end
      end
    end
  end

  describe Investment::Stock do
    describe 'validations' do
      describe ':symbol' do
        it 'is valid for uppercase up to 5 letters' do
          subject.symbol = 'GOOGL'
          expect(subject).to be_valid
        end

        it 'is invalid for long symbols' do
          subject.symbol = 'GOOGLL'
          expect(subject).to_not be_valid
        end

        it 'is invalid for lowercase' do
          subject.symbol = 'googl'
          expect(subject).to_not be_valid
        end

        it 'is invalid for 5 characters symbols ending in X' do
          subject.symbol = 'VAIPX'
          expect(subject).to_not be_valid
        end

        it 'is valid for symbols ending in X' do
          subject.symbol = 'X'
          expect(subject).to be_valid
        end

        it 'is valid for dot symbols' do
          subject.symbol = 'BRK.A'
          expect(subject).to be_valid
        end
      end
    end
  end

  describe Investment::MutualFund do
    describe 'validations' do
      describe ':symbol' do
        it 'is valid for uppercase 5 letters ending in X' do
          subject.symbol = 'VAIPX'
          expect(subject).to be_valid
        end

        it 'is invalid for letters not ending in X' do
          subject.symbol = 'GOOGL'
          expect(subject).to_not be_valid
        end

        it 'is invalid for not five characters' do
          subject.symbol = 'XXXX'
          expect(subject).to_not be_valid
        end
      end
    end
  end

  describe Investment::Cash do
    describe 'validations' do
      describe ':symbol' do
        it 'is valid for uppercase 3 letters' do
          subject.symbol = 'USD'
          expect(subject).to be_valid
        end

        it 'is invalid for lowercase' do
          subject.symbol = 'AONSZ'
          expect(subject).to_not be_valid
        end
      end
    end

    it 'has prices of 1' do
      expect(subject.current_price).to eql(1)
      expect(subject.year_high).to eql(1)
      expect(subject.year_low).to eql(1)
    end

    it 'has super awesome price_matcher' do
      matcher = subject.price_matcher(Date.current)
      expect(matcher[Date.current         ]).to eql(1)
      expect(matcher[Date.current-1000    ]).to eql(1)
      expect(matcher[Date.current-10000000]).to eql(1)
    end
  end

  describe Investment::Option do
    describe 'validations' do
      describe ':symbol' do
        it 'is valid for standard symbology' do
          subject.symbol = 'AAPL140920C00105000'
          expect(subject).to be_valid

          subject.symbol = 'A140920P00105000'
          expect(subject).to be_valid
        end

        it 'is invalid for weird symbols' do
          subject.symbol = 'AAAPL140920C00105000'
          expect(subject).to_not be_valid

          subject.symbol = 'AAAAAPL140920C00105000'
          expect(subject).to_not be_valid
        end

        it 'is invalid for non put/call' do
          subject.symbol = 'AAPL140920Z00105000'
          expect(subject).to_not be_valid
        end

        it 'is invalid for invalid strike' do
          subject.symbol = 'AAPL140920P00000'
          expect(subject).to_not be_valid
        end
      end
    end

    describe 'symbol' do
      subject { Investment::Option.new(symbol: 'AAPL140920C00102500') }

      it 'has correct underlying_symbol' do
        expect(subject.underlying_symbol).to eq('AAPL')
      end

      it 'has correct expiration_date' do
        expect(subject.expiration_date).to eq(Date.parse('2014-09-20'))
      end

      it 'is not put' do
        expect(subject).to_not be_put
      end

      it 'is call' do
        expect(subject).to be_call
      end

      it 'has correct strike_price' do
        expect(subject.strike_price).to eq('102.5'.to_d)
      end
    end
  end
end
