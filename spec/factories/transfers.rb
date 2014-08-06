FactoryGirl.define do
  factory :transfer do
    association :from_user, factory: :user
    association :to_user, factory: :user
    date        { Date.today - rand(100) }
    amount      { rand(10.0..1000.0).to_d.round(2) }
  end
end
