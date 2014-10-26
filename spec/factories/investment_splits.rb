FactoryGirl.define do
  factory :investment_split do
    investment
    date                   { Date.current - rand(300) }
    add_attribute(:before) { 1 }
    add_attribute(:after)  { rand(2..5) }
  end
end
