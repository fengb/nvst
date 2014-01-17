describe BestMatchHash do
  let(:hash) { BestMatchHash.new({'2013-01-01' => 50, '2013-01-05' => 60}, 40) }

  describe '#[]' do
    it 'returns matched value' do
      expect(hash['2013-01-01']).to eq(50)
      expect(hash['2013-01-05']).to eq(60)
    end

    it 'returns closest match' do
      expect(hash['2013-01-04']).to eq(50)
      expect(hash['9999-01-05']).to eq(60)
    end

    it 'returns default' do
      expect(hash['2012-12-31']).to eq(40)
    end
  end

  describe '#keys' do
    it 'returns keys in order' do
      expect(hash.keys).to eq(['2013-01-01', '2013-01-05'])
    end
  end

  describe '#each' do
    it 'yields in order' do
      yielded = []
      hash.each do |key, value|
        yielded << [key, value]
      end
      expect(yielded.size).to eq(2)
      expect(yielded[0]).to eq(['2013-01-01', 50])
      expect(yielded[1]).to eq(['2013-01-05', 60])
    end
  end

  describe '.sum' do
    it 'returns a special version that sums up values' do
      hash = BestMatchHash.sum('2013-01-03' => 1,
                               '2013-01-04' => 2,
                               '2013-01-05' => 3)
      expect(hash['2013-01-02']).to eq(0)
      expect(hash['2013-01-03']).to eq(1)
      expect(hash['2013-01-04']).to eq(3)
      expect(hash['2013-01-05']).to eq(6)
      expect(hash['2013-01-07']).to eq(6)
    end
  end
end
