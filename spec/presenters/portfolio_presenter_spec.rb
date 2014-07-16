require 'spec_helper'


describe PortfolioPresenter do
  describe '#value_at' do
    subject do
      PortfolioPresenter.new(activities: [
        double(investment: 'FOO', date: '2013-01-02', shares: 100),
        double(investment: 'FOO', date: '2013-01-03', shares: 100),
        double(investment: 'BAR', date: '2013-01-04', shares: 100)
      ])
    end

    it 'is 0 at 2013-01-01' do
      expect(subject.value_at('2013-01-01')).to eq(0)
    end

    it 'is 100 at 2013-01-02' do
      expect(subject).to receive(:price_for).with('FOO', '2013-01-02').and_return(1)
      expect(subject.value_at('2013-01-02')).to eq(100)
    end

    it 'is 200 at 2013-01-03' do
      expect(subject).to receive(:price_for).with('FOO', '2013-01-03').and_return(2)
      expect(subject.value_at('2013-01-03')).to eq(400)
    end

    it 'is 200 at 2013-01-04' do
      expect(subject).to receive(:price_for).with('FOO', '2013-01-04').and_return(2)
      expect(subject).to receive(:price_for).with('BAR', '2013-01-04').and_return(1)
      expect(subject.value_at('2013-01-04')).to eq(500)
    end
  end

  context 'cashflows' do
    subject do
      PortfolioPresenter.new(cashflows: [
        double(date: '2013-01-04', cashflow_amount: 10),
        double(date: '2013-01-05', cashflow_amount: 100),
        double(date: '2013-01-05', cashflow_amount: 200)
      ])
    end

    describe '#cashflows' do
      it 'is' do
        expect(subject.cashflows).to eq('2013-01-04' => 10,
                                        '2013-01-05' => 300)
      end
    end

    describe '#cashflow_at' do
      it 'is 0 on 2013-01-03' do
        expect(subject.cashflow_at('2013-01-03')).to eq(0)
      end

      it 'is 10 on 2013-01-04' do
        expect(subject.cashflow_at('2013-01-04')).to eq(10)
      end

      it 'is 300 on 2013-01-05' do
        expect(subject.cashflow_at('2013-01-05')).to eq(300)
      end

      it 'is 0 on 2013-01-06' do
        expect(subject.cashflow_at('2013-01-06')).to eq(0)
      end
    end

    describe '#principal_at' do
      it 'is 0 on 2013-01-03' do
        expect(subject.principal_at('2013-01-03')).to eq(0)
      end

      it 'is 10 on 2013-01-04' do
        expect(subject.principal_at('2013-01-04')).to eq(10)
      end

      it 'is 110 on 2013-01-05' do
        expect(subject.principal_at('2013-01-05')).to eq(310)
      end

      it 'is 110 on 2013-01-06' do
        expect(subject.principal_at('2013-01-06')).to eq(310)
      end
    end
  end
end
