describe Lot do
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
