FactoryGirl.define do
  factory :investment_split do
    investment
    date       { Date.today - rand(300) }
    before     { rand(1..2) }
    after      { rand(2..5) }
  end
end
