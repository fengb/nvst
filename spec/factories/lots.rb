FactoryGirl.define do
  factory :lot do
    investment
    open_date  { Date.today - rand(10..300) }
    open_price { rand(10.0..100.0).round(2) }

    after(:create) do |lot, evaluator|
      if lot.transactions.count == 0
        FactoryGirl.create(:transaction, lot: lot,
                                         date: lot.open_date,
                                         price: lot.open_price)
      end
    end
  end
end
