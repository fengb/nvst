describe Trade do
  context 'fee calculations' do
    subject do
      Trade.new(net_amount: 100,
                shares:     -11,
                price:       10)
    end

    specify '#fee is net_amount + investment_value' do
      expect(subject.fee).to eq(-10)
    end

    specify '#net_amount = - #adjustment * #investment_value' do
      expect(subject.net_amount).to be_within(0.001).of(-subject.adjustment*subject.investment_value)
    end
  end
end
