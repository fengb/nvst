require 'rails_helper'

describe Ownership do
  describe '.total_on' do
    let!(:ownerships) do
      [ FactoryBot.create(:ownership, date: '2013-01-01', units: 100),
        FactoryBot.create(:ownership, date: '2013-01-02', units: 200),
        FactoryBot.create(:ownership, date: '2013-01-03', units:  50)
      ]
    end

    it 'returns the total at a date' do
      expect(Ownership.total_on '2013-01-02').to eq(300)
    end
  end
end
