FactoryGirl.define do
  factory :contribution do
    date   { Date.today - rand(100) }
    amount { rand(10000..100000) }
    units  { rand(1000..100000) }

    ignore do
      generate_transactions true
    end

    after(:create) do |contribution, evaluator|
      contribution.generate_transactions! if evaluator.generate_transactions
    end
  end
end
