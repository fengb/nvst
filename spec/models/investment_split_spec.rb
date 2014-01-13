require 'spec_helper'


describe InvestmentSplit do
  describe '#adjustment_to_past' do
    it 'compensates for expected drop in price' do
      # Date       Price   Split  Adjusted Price
      # Today       1.00     2:1            1.00
      # Yesterday   2.00                    1.00
      investment_split = InvestmentSplit.new(after: 2, before: 1)
      expect(investment_split.adjustment_to_past * 2).to eq(1)
    end
  end
end
