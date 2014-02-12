require 'spec_helper'


describe PublicPortfolioPresenter do
  subject { PublicPortfolioPresenter.new(portfolio, normalize_to) }
  let(:normalize_to) { 1000 }
  let(:portfolio) do
    PortfolioPresenter::Stub.new([
      {date: '2013-01-31', value:   0, principal:   0},
      {date: '2013-02-01', value: 100, principal: 100},
      {date: '2013-02-02', value: 200, principal: 100},
    ])
  end

  describe '#gross_value_at' do
    it '== 0 when value_at == 0' do
      expect(subject.gross_value_at('2013-01-31')).to eq(0)
    end

    it '== normalize_to * value / principal' do
      expect(subject.gross_value_at('2013-02-01')).to eq(normalize_to)
      expect(subject.gross_value_at('2013-02-02')).to eq(normalize_to*2)
    end
  end
end
