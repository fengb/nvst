require 'rails_helper'

describe Ownership do
  describe '.total_on' do
    let!(:ownerships) do
      [ FactoryGirl.create(:ownership, date: '2013-01-01', units: 100),
        FactoryGirl.create(:ownership, date: '2013-01-02', units: 200),
        FactoryGirl.create(:ownership, date: '2013-01-03', units:  50)
      ]
    end

    it 'returns the total at a date' do
      expect(Ownership.total_on '2013-01-02').to eq(300)
    end
  end
end
