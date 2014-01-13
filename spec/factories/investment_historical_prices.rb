FactoryGirl.define do
  factory :investment_historical_price do
    investment
    date       { Date.today - rand(300) }
    high       { rand(50.0..200.0) }
    low        { high - rand(0.0..10.0) }
    close      { rand(low..high) }
    adjustment { rand(0.5..1.0) }
  end
end
