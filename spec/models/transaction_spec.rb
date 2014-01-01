describe Transaction do
  describe '#origination?' do
    let!(:lot)          { FactoryGirl.create(:lot) }
    let(:transaction1)  { lot.transactions.first }
    let!(:transaction2) { FactoryGirl.create(:transaction, lot: lot,
                                                           date: transaction1.date,
                                                           price: transaction1.price) }

    it 'is true when data matches lot' do
      expect(transaction1.origination?).to be(true)
      expect(transaction2.origination?).to be(true)
    end
  end
end
