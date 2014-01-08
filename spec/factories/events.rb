FactoryGirl.define do
  factory :event do
    association :src_investment, factory: :investment
    date        { Date.today - rand(100) }
    amount      { rand(10.0..1000.0) }
    category    { Event.category.values.sample }
  end
end
