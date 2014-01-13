require 'spec_helper'


describe InvestmentDividend do
  describe 'adjustment_to_past' do
    it 'compensates for expected drop in price' do
      # Date       Price   Dividend  Adjusted Price
      # Today       1.00       0.25            1.00
      # Yesterday   1.25                       1.00
      dividend = InvestmentDividend.new
      past_price = BigDecimal('1.25')
      dividend.stub(percent: BigDecimal('0.25') / past_price)
      expect(dividend.adjustment * past_price).to eq(1)
    end
  end

  describe '#percent' do
    it 'is amount / ex_previous_price' do
      dividend = FactoryGirl.create(:investment_dividend, amount: 10.0)
      dividend.stub(ex_previous_price: FactoryGirl.create(:investment_historical_price, close: 20.0))
      expect(dividend.percent).to eq(0.5)
    end
  end

  describe '#ex_previous_price' do
    let(:match) { FactoryGirl.create(:investment_historical_price) }
    it 'is price on previous day' do
      dividend = InvestmentDividend.create(ex_date: match.date + 1,
                                           investment: match.investment)
      expect(dividend.ex_previous_price).to eq(match)
    end

    it 'is price on latest date before today' do
      dividend = InvestmentDividend.create(ex_date: match.date + 100,
                                           investment: match.investment)
      expect(dividend.ex_previous_price).to eq(match)
    end

    it 'does not match current date' do
      dividend = InvestmentDividend.create(ex_date: match.date,
                                           investment: match.investment)
      expect(dividend.ex_previous_price).to be(nil)
    end

    it 'does not match alternate investments' do
      dividend = InvestmentDividend.create(ex_date: match.date + 1,
                                           investment: FactoryGirl.create(:investment))
      expect(dividend.ex_previous_price).to be(nil)
    end
  end
end
