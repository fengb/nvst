FactoryGirl.define do
  factory :trade do
    date       { Date.current - rand(0..300) }
    cash
    investment
    net_amount { rand(100.0..10000.0) }
    shares     { rand(10..100) }
    price      { rand(10.0..100.0).to_d.round(2) }
  end
end
