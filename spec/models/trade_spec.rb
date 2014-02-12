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

  context 'fee calculations' do
    subject do
      Trade.new.tap do |t|
        t.stub(raw_sell_value: 150,
               raw_buy_value: 145)
      end
    end

    describe '#fee' do
      it 'is raw_sell_value - raw_buy_value' do
        expect(subject.fee).to eq(subject.raw_sell_value - subject.raw_buy_value)
      end
    end

    describe '#sell_value' do
      it 'is raw_sell_value if buy_investment is not cash' do
        subject.stub(buy_investment: double(cash?: false))
        expect(subject.sell_value).to eq(subject.raw_sell_value)
      end

      it 'is raw_sell_value - fee if buy_investment is cash' do
        subject.stub(buy_investment: double(cash?: true))
        expect(subject.sell_value).to eq(subject.raw_sell_value - subject.fee)
      end
    end

    describe '#buy_value' do
      it 'is raw_buy_value + fee if buy_investment is not cash' do
        subject.stub(buy_investment: double(cash?: false))
        expect(subject.buy_value).to eq(subject.raw_buy_value + subject.fee)
      end

      it 'is raw_buy_value if buy_investment is cash' do
        subject.stub(buy_investment: double(cash?: true))
        expect(subject.buy_value).to eq(subject.raw_buy_value)
      end
    end

    specify '#sell_value == #buy_value' do
      10.times do
        trade = FactoryGirl.create(:trade)
        expect(trade.sell_value).to eq(trade.buy_value)
      end
    end
  end
end
