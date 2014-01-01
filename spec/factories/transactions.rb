FactoryGirl.define do
  factory :transaction do
    lot
    date   { Date.today - rand(1..300) }
    shares { rand(100.0..1000.0) }
    price  { rand(10.0..100.0) }
  end
end
