FactoryGirl.define do
  factory :investment do
    sequence(:symbol, 'A')
    name    { Faker::Company.name }

    factory :cash
  end
end
