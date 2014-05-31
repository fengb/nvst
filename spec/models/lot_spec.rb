require 'spec_helper'

describe Lot do
  describe '.corresponding' do
    let(:lot)    { FactoryGirl.create(:lot) }
    let(:shares) { lot.activities[0].shares }
    let(:data)   { {investment: lot.investment,
                    date:       lot.opening(:date),
                    price:      lot.opening(:price),
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
    let!(:activity1) { FactoryGirl.create(:activity, shares: 1) }
    let!(:lot)          { activity1.lot }

    context 'open lot' do
      it 'excludes lots opened at later date' do
        expect(Lot.open(during: lot.opening(:date) - 1)).to eq([])
      end

      it 'includes all outstanding lots' do
        expect(Lot.open).to eq([lot])
      end

      it 'includes lots opened on date' do
        expect(Lot.open(during: lot.opening(:date))).to eq([lot])
      end

      it 'includes lots opened before date' do
        expect(Lot.open(during: lot.opening(:date) + 10000)).to eq([lot])
      end

      it 'includes not-fully-closed lots' do
        FactoryGirl.create(:activity, lot: lot,
                                         date: lot.opening(:date) + 1,
                                         shares: -0.5)
        expect(Lot.open(during: lot.opening(:date) + 10)).to eq([lot])
      end

      it 'includes lots in the same direction' do
        expect(Lot.open(direction: '+')).to eq([lot])
      end

      it 'excludes lots in the opposite direction' do
        expect(Lot.open(direction: '-')).to eq([])
      end
    end

    context 'closed lots' do
      let(:close_date)    { Date.today - 10 }
      let!(:activity2) { FactoryGirl.create(:activity, lot: lot,
                                                             shares: -1,
                                                             date: close_date) }

      it 'excludes closed lots' do
        expect(Lot.open).to eq([])
      end

      it 'includes lots closed later' do
        expect(Lot.open(during: close_date - 1)).to eq([lot])
      end
    end
  end

  context 'gains' do
    subject { FactoryGirl.create(:lot) }
    let!(:opening_activity) do
      FactoryGirl.create(:activity, price:  100,
                                       shares: 100)
    end
    let!(:closing_activity) do
      FactoryGirl.create(:activity, lot:    opening_activity.lot,
                                       date:   Date.today,
                                       price:  110,
                                       shares: -90)
    end
    subject { opening_activity.lot }

    it 'has realized gain of (110-100)*90 = 900' do
      expect(subject.realized_gain).to eq(900)
    end

    it 'has unrealized gain of (120-100)*(100-90) = 200' do
      subject.stub(current_price: 120)
      expect(subject.unrealized_gain).to eq(200)
    end
  end
end
