require 'spec_helper'


describe PublicPortfolioPresenter do
  subject { PublicPortfolioPresenter.new(portfolio, normalize_to) }
  let(:normalize_to) { 1000 }
  let(:portfolio) do
    PortfolioPresenter::Stub.new([
      {date: '2013-02-01'.to_date, value:  2, principal:  2, cashflow:  2},
      {date: '2013-02-02'.to_date, value:  4, principal:  2, cashflow:  0},
      {date: '2013-02-03'.to_date, value: 14, principal: 12, cashflow: 10},
      {date: '2013-02-04'.to_date, value: 21, principal: 12, cashflow:  0},
      {date: '2013-02-05'.to_date, value: 24, principal: 15, cashflow:  3},
    ])
  end

  describe '#gross_value_at' do
    it '== 0 with no portfolio values' do
      expect(subject.gross_value_at('2013-01-31'.to_date)).to eq(0)
    end

    it '== 1000 principal amount' do
      expect(subject.gross_value_at('2013-02-01'.to_date)).to eq(normalize_to)
    end

    it 'accounts for value growth' do
      expect(subject.gross_value_at('2013-02-02'.to_date)).to eq(normalize_to*2)
    end

    it 'ignores further principal growth' do
      expect(subject.gross_value_at('2013-02-03'.to_date)).to eq(normalize_to*2)
    end

    it 'accounts for value growth after further principal growth' do
      expect(subject.gross_value_at('2013-02-04'.to_date)).to eq(normalize_to*3)
    end

    it 'accounts for two adjustments' do
      expect(subject.gross_value_at('2013-02-05'.to_date)).to eq(normalize_to*3)
    end
  end
end
