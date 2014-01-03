FactoryGirl.define do
  factory :ownership do
    user
    date  { Date.today - rand(10..300) }
    units { rand(10.0..100.0) }
  end
end
