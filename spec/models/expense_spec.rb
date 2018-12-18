describe Expense do
  describe '.year' do
    let!(:expenses) do
      [FactoryBot.create(:expense, date: '2013-01-01'),
       FactoryBot.create(:expense, date: '2014-01-01')]
    end

    it 'pulls expenses for a specific year' do
      e2013 = Expense.year(2013)
      expect(e2013.count).to eq(1)
      expect(e2013.first).to eq(expenses[0])

      e2014 = Expense.year(2014)
      expect(e2014.count).to eq(1)
      expect(e2014.first).to eq(expenses[1])
    end
  end
end
