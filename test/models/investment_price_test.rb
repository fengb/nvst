require 'test_helper'

describe InvestmentPrice do
  describe '.year_range' do
    before do
      @prices = {
        0 => FactoryGirl.create(:investment_price, date: Date.today),
        365 => FactoryGirl.create(:investment_price, date: Date.today - 365),
        366 => FactoryGirl.create(:investment_price, date: Date.today - 366)
      }
    end

    it 'includes investments from up to 1 year ago' do
      expect(InvestmentPrice.year_range).to_include @prices[0]
      expect(InvestmentPrice.year_range).to_include @prices[365]
    end

    it 'does not include from over 1 year ago' do
      expect(InvestmentPrice.year_range).to_not_include @prices[366]
    end
  end
end
