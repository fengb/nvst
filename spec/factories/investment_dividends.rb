FactoryGirl.define do
  factory :investment_dividend do
    investment
    ex_date    { Date.current - rand(300) }
    amount     { rand(0.01..3.0).to_d.round(2) }
  end
end
