require 'spec_helper'


describe LotSummaryPresenter do
  describe '#unique_by' do
    it 'returns the unique item' do
      l = LotSummaryPresenter.new([
        double(key: 'uno'),
        double(key: 'uno'),
      ])
      expect(l.send(:unique_by, &:key)).to eq('uno')
    end

    it 'returns nil when the fields are not unique' do
      l = LotSummaryPresenter.new([
        double(key: 'uno'),
        double(key: 'dos'),
      ])
      expect(l.send(:unique_by, &:key)).to be(nil)
    end
  end

  describe '#sum_by' do
    it 'returns the sum item' do
      l = LotSummaryPresenter.new([
        double(key: 12),
        double(key: 34),
      ])
      expect(l.send(:sum_by, &:key)).to eq(46)
    end
  end
end
