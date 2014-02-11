describe Lot do
  describe '.corresponding' do
    let(:lot)    { FactoryGirl.create(:lot) }
    let(:shares) { lot.transactions[0].shares }
    let(:data)   { {investment: lot.investment,
                    date:       lot.open_date,
                    price:      lot.open_price,
                    shares:     shares } }

    it 'finds existing when all data matches' do
      expect(Lot.corresponding(data)).to eq(lot)
    end

    it 'finds existing when shares have same +/- sign' do
      expect(Lot.corresponding(data.merge shares: shares / shares.abs)).to eq(lot)
    end

    it 'does not find existing when shares have opposite sign' do
      expect(Lot.corresponding(data.merge shares: -shares)).to be(nil)
    end
  end

  context 'gains' do
    let(:lot) { FactoryGirl.build(:lot, open_price: 100) }
    let!(:transactions) do
      [ FactoryGirl.create(:transaction, lot:    lot,
                                         price:  lot.open_price,
                                         shares: 100),
        FactoryGirl.create(:transaction, lot:    lot,
                                         date:   Date.today,
                                         price:  110,
                                         shares: -90)
      ]
    end

    it 'has realized gain of (110-100)*90 = 900' do
      expect(lot.realized_gain).to eq(900)
    end

    it 'has unrealized gain of (120-100)*(100-90) = 200' do
      lot.stub(current_price: 120)
      expect(lot.unrealized_gain).to eq(200)
    end
  end
end
