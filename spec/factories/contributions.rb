FactoryGirl.define do
  factory :contribution do
    user
    date   { Date.current - rand(100) }
    amount { rand(10000.0..100000.0).to_d.round(2) }
  end
end
