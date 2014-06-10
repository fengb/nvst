require 'spec_helper'

describe Position do
  describe '.corresponding' do
    let(:position) { FactoryGirl.create(:position) }
    let(:shares)   { position.activities[0].shares }
    let(:data)     { {investment: position.investment,
                      tax_date:   position.opening(:tax_date),
                      price:      position.opening(:price),
                      shares:     shares } }

    it 'finds existing when all data matches' do
      expect(Position.corresponding(data)).to eq(position)
    end

    it 'finds existing when shares have same +/- sign' do
      expect(Position.corresponding(data.merge shares: shares / shares.abs)).to eq(position)
    end

    it 'does not find existing when shares have opposite sign' do
      expect(Position.corresponding(data.merge shares: -shares)).to be(nil)
    end

    it 'does not find existing when adjustment does not match' do
      expect(Position.corresponding(data.merge adjustment: 1)).to be(nil)
    end
  end

  describe '.open' do
    let!(:activity1) { FactoryGirl.create(:activity, shares: 1) }
    let!(:position)  { activity1.position }

    context 'open position' do
      it 'excludes positions opened at later date' do
        expect(Position.open(during: position.opening(:date) - 1)).to eq([])
      end

      it 'includes all outstanding positions' do
        expect(Position.open).to eq([position])
      end

      it 'includes positions opened on date' do
        expect(Position.open(during: position.opening(:date))).to eq([position])
      end

      it 'includes positions opened before date' do
        expect(Position.open(during: position.opening(:date) + 10000)).to eq([position])
      end

      it 'includes not-fully-closed positions' do
        FactoryGirl.create(:activity, position: position,
                                         date: position.opening(:date) + 1,
                                         shares: -0.5)
        expect(Position.open(during: position.opening(:date) + 10)).to eq([position])
      end

      it 'includes positions in the same direction' do
        expect(Position.open(direction: '+')).to eq([position])
      end

      it 'excludes positions in the opposite direction' do
        expect(Position.open(direction: '-')).to eq([])
      end
    end

    context 'closed positions' do
      let(:close_date) { Date.today - 10 }
      let!(:activity2) { FactoryGirl.create(:activity, position: position,
                                                       shares: -1,
                                                       date: close_date) }

      it 'excludes closed positions' do
        expect(Position.open).to eq([])
      end

      it 'includes positions closed later' do
        expect(Position.open(during: close_date - 1)).to eq([position])
      end
    end
  end

  context 'gains' do
    subject { FactoryGirl.create(:position) }
    let!(:opening_activity) do
      FactoryGirl.create(:activity, price:  100,
                                    shares: 100)
    end
    let!(:closing_activity) do
      FactoryGirl.create(:activity, position: opening_activity.position,
                                    date:     Date.today,
                                    price:    110,
                                    shares:   -90)
    end
    subject { opening_activity.position }

    it 'has realized gain of (110-100)*90 = 900' do
      expect(subject.realized_gain).to eq(900)
    end

    it 'has unrealized gain of (120-100)*(100-90) = 200' do
      subject.stub(current_price: 120)
      expect(subject.unrealized_gain).to eq(200)
    end
  end
end
