describe Event do
  describe '.year' do
    let!(:events) do
      [FactoryBot.create(:event, date: '2013-01-01'),
       FactoryBot.create(:event, date: '2014-01-01')]
    end

    it 'pulls events for a specific year' do
      e2013 = Event.year(2013)
      expect(e2013.count).to eq(1)
      expect(e2013.first).to eq(events[0])

      e2014 = Event.year(2014)
      expect(e2014.count).to eq(1)
      expect(e2014.first).to eq(events[1])
    end
  end
end
