describe Lot do
  describe '.corresponding' do
    let(:lot) { FactoryGirl.create(:lot) }

    it 'finds the lot by investment / origination date / origination price' do
      search = Lot.corresponding(investment:        lot.investment,
                                 origination_date:  lot.origination_date,
                                 origination_price: lot.origination_price)
      expect(search).to eq(lot)
    end

    it 'finds nil when nothing matches' do
      search = Lot.corresponding(investment:     lot.investment,
                                 origination_date:  lot.origination_date + 1,
                                 origination_price: lot.origination_price)
      expect(search).to be(nil)
    end
  end

  context 'gains' do
    let(:lot) { FactoryGirl.build(:lot) }
    let!(:transactions) do
      [ FactoryGirl.create(:transaction, lot:    lot,
                                         price:  100,
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