FactoryBot.define do
  factory :investment do
    sequence(:symbol, 'A')
    name    { FFaker::Company.name }

    factory :cash
  end
end
