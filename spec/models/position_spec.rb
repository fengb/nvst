require 'rails_helper'

describe Position do
  context 'with opening buy activity' do
    subject do
      FactoryBot.create(:position, opening_activity: {shares: 100})
    end

    it { is_expected.to be_long }
    it { is_expected.to_not be_short }

    it 'is found via Position.long' do
      expect(Position.long).to include(subject)
    end
  end

  context 'with opening sell activity' do
    subject do
      FactoryBot.create(:position, opening_activity: {shares: -100})
    end

    it { is_expected.to be_short }
    it { is_expected.to_not be_long }

    it 'is found via Position.short' do
      expect(Position.short).to include(subject)
    end
  end

  describe '.open' do
    let!(:position) do
      FactoryBot.create(:position, opening_activity: {shares: 1})
    end

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
        FactoryBot.create(:activity, position: position,
                                      date: position.opening(:date) + 1,
                                      shares: -0.5)
        expect(Position.open(during: position.opening(:date) + 10)).to eq([position])
      end
    end

    context 'closed positions' do
      let(:close_date) { Date.current - 10 }
      let!(:activity2) { FactoryBot.create(:activity, position: position,
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
    context 'long position' do
      subject do
        FactoryBot.create(:position, opening_activity: {price:  100,
                                                         shares: 100})
      end
      let!(:closing_activity) do
        FactoryBot.create(:activity, position: subject,
                                      date:     Date.current,
                                      price:    110,
                                      shares:   -90)
      end

      it 'has realized_gain of (110-100) * 90 = 900' do
        expect(subject.realized_gain).to eq(900)
      end

      it 'has unrealized_gain of (120-100) * (100-90) = 200' do
        allow(subject).to receive_messages(current_price: 120)
        expect(subject.unrealized_gain).to eq(200)
      end

      it 'has unrealized_gain_percent of 20/100 = 20%' do
        allow(subject).to receive_messages(unrealized_gain: 200)
        expect(subject.unrealized_gain_percent).to eq('0.2'.to_d)
      end
    end

    context 'short position' do
      subject do
        FactoryBot.create(:position, opening_activity: {price:  100,
                                                         shares: -100})
      end
      let!(:closing_activity) do
        FactoryBot.create(:activity, position: subject,
                                      date:     Date.current,
                                      price:    90,
                                      shares:   90)
      end

      it 'has realized_gain of (100-90) * 90 = 900' do
        expect(subject.realized_gain).to eq(900)
      end

      it 'has unrealized_gain of (100-80) * (100-90) = 200' do
        allow(subject).to receive_messages(current_price: 80)
        expect(subject.unrealized_gain).to eq(200)
      end

      it 'has unrealized_gain_percent of 20/100 = 20%' do
        allow(subject).to receive_messages(unrealized_gain: 200)
        expect(subject.unrealized_gain_percent).to eq('0.2'.to_d)
      end
    end
  end
end
