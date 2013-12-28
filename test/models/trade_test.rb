describe Trade do
  describe '#sell_value' do
    it 'is sell_shares * sell_price' do
      t = Trade.new(sell_shares: '20', sell_price: '1.5')
      expect(t.sell_value).to_equal 30
    end
  end

  describe '#buy_value' do
    it 'is buy_shares * buy_price' do
      t = Trade.new(sell_shares: '30.50', sell_price: '2')
      expect(t.sell_value).to_equal 61
    end
  end
end
