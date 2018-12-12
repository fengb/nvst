FactoryBot.define do
  factory :event do
    association :src_investment, factory: :investment
    date        { Date.current - rand(100) }
    amount      { rand(10.0..1000.0).to_d.round(2) }
    category    { Event.categories.values.sample }
  end
end
