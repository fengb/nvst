describe Trade do
  describe '#raw_sell_value' do
    it 'is sell_shares * sell_price' do
      t = Trade.new(sell_shares: '20', sell_price: '1.5')
      expect(t.raw_sell_value).to eq(30)
    end
  end

  describe '#raw_buy_value' do
    it 'is buy_shares * buy_price' do
      t = Trade.new(buy_shares: '30.50', buy_price: '2')
      expect(t.raw_buy_value).to eq(61)
    end
  end

  describe '#fee' do
    it 'is raw_sell_value - raw_buy_value' do
      t = Trade.new
      t.stub(raw_sell_value: 150,
             raw_buy_value:  145)
      expect(t.fee).to eq(t.raw_sell_value - t.raw_buy_value)
    end
  end

  describe '#sell_value' do
    it 'is raw_sell_value if buy_investment is not cash' do
      t = Trade.new
      t.stub(raw_sell_value: 101,
             buy_investment: double(cash?: false))
      expect(t.sell_value).to eq(t.raw_sell_value)
    end

    it 'is raw_sell_value - fee if buy_investment is cash' do
      t = Trade.new
      t.stub(raw_sell_value: 101,
             fee:              4,
             buy_investment: double(cash?: true))
      expect(t.sell_value).to eq(t.raw_sell_value - t.fee)
    end
  end

  describe '#buy_value' do
    it 'is raw_buy_value - fee if buy_investment is not cash' do
      t = Trade.new
      t.stub(raw_buy_value:  101,
             fee:              4,
             buy_investment: double(cash?: false))
      expect(t.buy_value).to eq(t.raw_buy_value - t.fee)
    end

    it 'is raw_buy_value if buy_investment is cash' do
      t = Trade.new
      t.stub(raw_buy_value:  101,
             buy_investment: double(cash?: true))
      expect(t.buy_value).to eq(t.raw_buy_value)
    end
  end
end
