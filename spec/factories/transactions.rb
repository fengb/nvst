FactoryGirl.define do
  factory :transaction do
    date   { Date.today - rand(1..300) }
    shares { rand(100.0..1000.0) }
    price  { rand(10.0..100.0) }

    after(:build) do |transaction, evaluator|
      transaction.lot ||= FactoryGirl.build(:lot, open_date: transaction.date,
                                                  open_price: transaction.price) do |lot|
        lot.transactions << transaction
      end
    end
  end
end
