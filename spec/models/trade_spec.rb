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

  describe '#adjust_sell?' do
    it 'is true when buy_investment is cash' do
      allow(subject).to receive_messages(buy_investment: double(cash?: true))
      expect(subject.adjust_sell?).to be(true)
    end

    it 'is false when buy_investment is not cash' do
      allow(subject).to receive_messages(buy_investment: double(cash?: false))
      expect(subject.adjust_sell?).to be(false)
    end
  end

  context 'fee calculations' do
    subject do
      Trade.new do |t|
        allow(t).to receive_messages(raw_sell_value: 150,
                                     raw_buy_value: 145)
      end
    end

    describe '#fee' do
      it 'is raw_sell_value - raw_buy_value' do
        expect(subject.fee).to eq(subject.raw_sell_value - subject.raw_buy_value)
      end
    end

    context 'adjust_sell?' do
      before do
        allow(subject).to receive_messages(adjust_sell?: true)
      end

      specify '#sell_value == #raw_buy_value' do
        expect(subject.sell_value).to eq(subject.raw_buy_value)
      end

      specify '#buy_value == #raw_buy_value' do
        expect(subject.buy_value).to eq(subject.raw_buy_value)
      end

      specify '#sell_adjustment == (raw_sell_value - fee) / raw_sell_value' do
        mathed = Rational(subject.raw_sell_value - subject.fee, subject.raw_sell_value)
        expect(subject.sell_adjustment).to eq(mathed)
      end

      specify '#buy_adjustment == 1' do
        expect(subject.buy_adjustment).to eq(1)
      end
    end

    context '!adjust_sell?' do
      before do
        allow(subject).to receive_messages(adjust_sell?: false)
      end

      specify '#sell_value == #raw_sell_value' do
        expect(subject.sell_value).to eq(subject.raw_sell_value)
      end

      specify '#buy_value == #raw_sell_value' do
        expect(subject.buy_value).to eq(subject.raw_sell_value)
      end

      specify '#sell_adjustment == 1' do
        expect(subject.sell_adjustment).to eq(1)
      end

      specify '#buy_adjustment == (raw_buy_value + fee) / raw_buy_value' do
        mathed = Rational(subject.raw_buy_value + subject.fee, subject.raw_buy_value)
        expect(subject.buy_adjustment).to eq(mathed)
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
