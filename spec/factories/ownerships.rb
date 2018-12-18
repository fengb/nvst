FactoryBot.define do
  factory :ownership do
    user
    date  { Date.current - rand(10..300) }
    units { rand(10.0..100.0) }
  end
end
