FactoryGirl.define do
  factory :expiration do
    investment
    date   { Date.current - rand(100) }
    shares { rand(1..100).to_d }
  end
end
