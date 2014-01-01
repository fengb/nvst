describe Lot do
  describe '.corresponding' do
    let(:lot) { FactoryGirl.create(:lot) }

    it 'finds the lot by investment / purchase date / purchase price' do
      search = Lot.corresponding(investment:     lot.investment,
                                 purchase_date:  lot.purchase_date,
                                 purchase_price: lot.purchase_price)
      expect(search).to eq(lot)
    end

    it 'finds nil when nothing matches' do
      search = Lot.corresponding(investment:     lot.investment,
                                 purchase_date:  lot.purchase_date + 1,
                                 purchase_price: lot.purchase_price)
      expect(search).to be(nil)
    end
  end
end
