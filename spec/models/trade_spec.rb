describe Trade do
  describe '#sell_value' do
    it 'is sell_shares * sell_price' do
      t = Trade.new(sell_shares: '20', sell_price: '1.5')
      expect(t.sell_value).to eq(30)
    end
  end

  describe '#buy_value' do
    it 'is buy_shares * buy_price' do
      t = Trade.new(sell_shares: '30.50', sell_price: '2')
      expect(t.sell_value).to eq(61)
    end
  end

  describe '#fee' do
    it 'is sell_value - buy_value' do
      t = Trade.new
      t.stub(sell_value: 150,
             buy_value:  145)
      expect(t.fee).to eq(5)
    end
  end
end
