FactoryGirl.define do
  factory :contribution do
    date   { Date.today - rand(100) }
    amount { rand(10000..100000) }
    units  { rand(1000..100000) }
  end
end
