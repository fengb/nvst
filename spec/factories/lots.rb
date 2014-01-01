FactoryGirl.define do
  factory :lot do
    investment

    after(:create) do |lot, evaluator|
      if lot.transactions.count == 0
        FactoryGirl.create(:transaction, lot: lot)
      end
    end
  end
end
