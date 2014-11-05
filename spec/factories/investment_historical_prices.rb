FactoryGirl.define do
  factory :investment_historical_price do
    investment
    date       { Date.current - rand(300) }
    high       { rand(50.0..200.0).to_d.round(2) }
    low        { high - rand(0.01..10.0).to_d.round(2) }
    close      { rand(low..high).to_d.round(2) }
    adjustment { rand(0.5..1.0).to_d.round(2) }
  end
end
