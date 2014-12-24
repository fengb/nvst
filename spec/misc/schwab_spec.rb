RSpec.describe Schwab do
  describe Schwab::Transaction do
    describe '.parse' do
      let(:csv) do
        <<-CSV
"Transactions  for account XXXX-3910 as of 12/20/2014 21:16:49 ET"
"Date","Action","Symbol","Description","Quantity","Price","Fees & Comm","Amount",
"12/16/2014 as of 12/15/2014","Bank Interest","","BANK INT","","","","$0.11",
"12/13/2014","Buy                 ","F","FORD MOTOR COMPANY NEW","1","$14.39","$8.95","-$23.34",
        CSV
      end

      it 'has correct rows' do
        array = Schwab::Transaction.parse(csv)
        expect(array.size).to eq(2)
      end

      it 'parses correct dates' do
        array = Schwab::Transaction.parse(csv)
        expect(array[0]).to have_attributes(
          date:  Date.new(2014, 12, 16),
          as_of: Date.new(2014, 12, 15)
        )
        expect(array[1].date).to eq(Date.new(2014, 12, 13))
      end

      it 'parses correct numbers' do
        array = Schwab::Transaction.parse(csv)
        expect(array[0]).to have_attributes(
          quantity: nil,
          price: nil,
          fees: nil,
          amount: '0.11'.to_d
        )
        expect(array[1]).to have_attributes(
          quantity: 1,
          price:    '14.39'.to_d,
          fees:      '8.95'.to_d,
          amount:  '-23.34'.to_d
        )
      end

      it 'removes extra whitespace' do
        array = Schwab::Transaction.parse(csv)
        expect(array[1].action).to eq('Buy')
      end
    end
  end
end
