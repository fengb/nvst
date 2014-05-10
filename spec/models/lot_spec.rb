require 'spec_helper'

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

    it 'does not find existing when adjustment does not match' do
      expect(Lot.corresponding(data.merge adjustment: 1)).to be(nil)
    end
  end

  describe '.open' do
    let!(:transaction1) { FactoryGirl.create(:transaction, shares: 1) }
    let!(:lot)          { transaction1.lot }

    context 'open lot' do
      it 'excludes lots opened at later date' do
        expect(Lot.open(at: lot.open_date - 1)).to eq([])
      end

      it 'includes lots opened at date' do
        expect(Lot.open(at: lot.open_date)).to eq([lot])
      end

      it 'includes lots opened at before date' do
        expect(Lot.open(at: lot.open_date + 10000)).to eq([lot])
      end

      it 'includes not-fully-closed lots' do
        FactoryGirl.create(:transaction, lot: lot,
                                         date: lot.open_date + 1,
                                         shares: -0.5)
        expect(Lot.open(at: lot.open_date + 10)).to eq([lot])
      end
    end

    it 'includes all outstanding lots' do
      expect(Lot.open).to eq([lot])
    end

    it 'includes lots in the same direction' do
      expect(Lot.open(direction: '+')).to eq([lot])
    end

    it 'excludes lots in the opposite direction' do
      expect(Lot.open(direction: '-')).to eq([])
    end

    it 'excludes closed lots' do
      FactoryGirl.create(:transaction, lot: lot,
                                       shares: -1)
      expect(Lot.open).to eq([])
    end
  end

  context 'gains' do
    subject { FactoryGirl.build(:lot, open_price: 100) }
    let!(:transactions) do
      [ FactoryGirl.create(:transaction, lot:    subject,
                                         price:  subject.open_price,
                                         shares: 100),
        FactoryGirl.create(:transaction, lot:    subject,
                                         date:   Date.today,
                                         price:  110,
                                         shares: -90)
      ]
    end

    it 'has realized gain of (110-100)*90 = 900' do
      expect(subject.realized_gain).to eq(900)
    end

    it 'has unrealized gain of (120-100)*(100-90) = 200' do
      subject.stub(current_price: 120)
      expect(subject.unrealized_gain).to eq(200)
    end
  end
end
