FactoryBot.define do
  factory :activity do
    association :source, factory: :contribution

    date       { Date.current - rand(100..300) }
    tax_date   { date }
    shares     { rand(100.0..1000.0).to_d.round(2) }
    price      { rand(10.0..100.0).to_d.round(2) }

    transient do
      investment { FactoryBot.build :investment }
    end

    after(:build) do |activity, evaluator|
      if activity.position.nil?
        activity.position = FactoryBot.build(:position, investment: evaluator.investment)
        activity.is_opening = true
      end
    end
  end
end
