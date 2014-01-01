FactoryGirl.define do
  factory :lot do
    investment

    after(:create) do |lot, evaluator|
      FactoryGirl.create(:transaction, lot: lot)
    end
  end
end
