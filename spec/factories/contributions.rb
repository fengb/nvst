FactoryGirl.define do
  factory :contribution do
    date   { Date.today - rand(100) }
    amount { rand(10000.0..100000.0).to_d.round(2) }

    ignore do
      generate_activities true
    end

    after(:create) do |contribution, evaluator|
      contribution.generate_activities! if evaluator.generate_activities
    end
  end
end
