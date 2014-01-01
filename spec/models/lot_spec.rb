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

  describe '#purchase_transactions' do
    let!(:lot)          { FactoryGirl.create(:lot) }
    let(:transaction1)  { lot.transactions.first }
    let!(:transaction2) { FactoryGirl.create(:transaction, lot: lot,
                                                           date: transaction1.date,
                                                           price: transaction1.price) }

    it 'has both transactions as purchase transactions' do
      expect(lot.purchase_transactions).to include(transaction1)
      expect(lot.purchase_transactions).to include(transaction2)
    end
  end
end
