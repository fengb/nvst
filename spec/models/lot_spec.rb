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

  describe '#origination_transactions' do
    let!(:lot)          { FactoryGirl.create(:lot) }
    let(:transaction1)  { lot.transactions.first }
    let!(:transaction2) { FactoryGirl.create(:transaction, lot: lot,
                                                           date: transaction1.date,
                                                           price: transaction1.price) }

    it 'has both transactions as origination transactions' do
      expect(lot.origination_transactions).to include(transaction1)
      expect(lot.origination_transactions).to include(transaction2)
    end
  end
end
