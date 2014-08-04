describe Transfer do
  describe '#generate_ownerships!' do
    subject do
      Transfer.create(date:      Date.today - 5,
                      amount:    1942.12,
                      from_user: FactoryGirl.create(:user))
    end

    it 'creates both from and to ownerships' do
      subject.generate_ownerships!
      expect(subject.from_ownership.user).to eq(subject.from_user)
      expect(subject.to_ownership.user).to eq(User.fee_collector)
    end

    it 'sums generated ownership units to 0' do
      subject.generate_ownerships!
      expect(subject.ownerships.sum(:units)).to eq(0)
    end
  end
end
