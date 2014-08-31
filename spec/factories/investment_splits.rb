FactoryGirl.define do
  factory :investment_split do
    investment
    date       { Date.current - rand(300) }
    before     1
    after      { rand(2..5) }
  end
end
