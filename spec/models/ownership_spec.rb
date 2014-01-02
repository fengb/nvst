require 'spec_helper'

describe Ownership do
  describe '.total_at' do
    let!(:ownerships) do
      [ Ownership.create(date: '2013-01-01', units: 100),
        Ownership.create(date: '2013-01-02', units: 200),
        Ownership.create(date: '2013-01-03', units:  50)
      ]
    end

    it 'returns the total at a date' do
      expect(Ownership.total_at '2013-01-02').to eq(300)
    end
  end
end
