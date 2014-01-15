FactoryGirl.define do
  factory :trade do
    date        { Date.today - rand(0..300) }
    association :sell_investment, factory: :investment
    sell_shares { rand(10..100) }
    sell_price  { rand(10.0..100.0).round(2) }

    association :buy_investment, factory: :investment
    buy_shares  { rand(10..100) }
    buy_price   { rand(10.0..100.0).round(2) }
  end
end
