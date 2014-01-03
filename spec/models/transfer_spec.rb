describe Transfer do
  describe '#generate_ownerships!' do
    let(:transfer) { Transfer.new(date:      Date.today - 5,
                                  amount:    1942.12,
                                  from_user: FactoryGirl.create(:user),
                                  to_user:   FactoryGirl.create(:user)) }

    it 'creates both from and to ownerships' do
      transfer.generate_ownerships!
      expect(transfer.from_ownership.user).to eq(transfer.from_user)
      expect(transfer.to_ownership.user).to eq(transfer.to_user)
    end

    it 'sums generated ownership units to 0' do
      transfer.generate_ownerships!
      expect(transfer.ownerships.map(&:units).sum).to eq(0)
    end
  end
end
