require 'best_match_hash'


describe BestMatchHash do
  describe '#[]' do
    let(:hash) { BestMatchHash.new({'2013-01-01' => 50, '2013-01-05' => 60}, 40) }

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
end
