FactoryGirl.define do
  factory :investment_dividend do
    investment
    ex_date    { Date.today - rand(300) }
    amount     { rand(0.01..3.0) }
  end
end
