require 'rails_helper'


describe InvestmentDividend do
  describe '#price_adjustment' do
    it 'compensates for expected drop in price' do
      # Date       Price   Dividend  Adjusted Price
      # Today       1.00       0.25            1.00
      # Yesterday   1.25                       1.00
      dividend = InvestmentDividend.new
      past_price = BigDecimal('1.25')
      allow(dividend).to receive_messages(percent: BigDecimal('0.25') / past_price)
      expect(dividend.price_adjustment * past_price).to eq(1)
    end
  end

  describe '#percent' do
    it 'is amount / ex_previous_price' do
      dividend = FactoryBot.create(:investment_dividend, amount: 10.0)
      allow(dividend).to receive_messages(ex_previous_price: FactoryBot.create(:investment_historical_price, close: 20.0))
      expect(dividend.percent).to eq(0.5)
    end
  end

  describe '#ex_previous_price' do
    let(:match) { FactoryBot.create(:investment_historical_price) }
    subject { InvestmentDividend.create(investment: match.investment) }

    it 'is price on previous day' do
      subject.ex_date = match.date + 1
      expect(subject.ex_previous_price).to eq(match)
    end

    it 'is price on latest date before today' do
      subject.ex_date = match.date + 100
      expect(subject.ex_previous_price).to eq(match)
    end

    it 'does not match current date' do
      subject.ex_date = match.date
      expect(subject.ex_previous_price).to be(nil)
    end

    it 'does not match alternate investments' do
      subject.ex_date = match.date + 1
      subject.investment = FactoryBot.create(:investment)
      expect(subject.ex_previous_price).to be(nil)
    end
  end
end
