FactoryGirl.define do
  factory :investment_price do
    date  { Date.today }
    high  { rand(50.0..200.0) }
    low   { high - rand(10) }
    close { rand(low..high) }
  end
end
