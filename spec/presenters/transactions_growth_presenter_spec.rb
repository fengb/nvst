require 'spec_helper'


describe TransactionsGrowthPresenter do
  describe '#value_at' do
    let(:presenter) do
      TransactionsGrowthPresenter.new([
        double(investment: 'FOO', date: '2013-01-02', shares: 100),
        double(investment: 'FOO', date: '2013-01-03', shares: 100),
        double(investment: 'BAR', date: '2013-01-04', shares: 100)
      ])
    end

    it 'is 0 at 2013-01-01' do
      expect(presenter.value_at('2013-01-01')).to eq(0)
    end

    it 'is 100 at 2013-01-02' do
      presenter.should_receive(:price_for).with('FOO', '2013-01-02').and_return(1)
      expect(presenter.value_at('2013-01-02')).to eq(100)
    end

    it 'is 200 at 2013-01-03' do
      presenter.should_receive(:price_for).with('FOO', '2013-01-03').and_return(2)
      expect(presenter.value_at('2013-01-03')).to eq(400)
    end

    it 'is 200 at 2013-01-04' do
      presenter.should_receive(:price_for).with('FOO', '2013-01-04').and_return(2)
      presenter.should_receive(:price_for).with('BAR', '2013-01-04').and_return(1)
      expect(presenter.value_at('2013-01-04')).to eq(500)
    end
  end
end
