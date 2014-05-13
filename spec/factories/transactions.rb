FactoryGirl.define do
  factory :transaction do
    date       { Date.today - rand(100..300) }
    shares     { rand(100.0..1000.0) }
    price      { rand(10.0..100.0) }

    after(:build) do |transaction, evaluator|
      if transaction.lot.nil?
        transaction.lot = FactoryGirl.build(:lot) do |lot|
          lot.transactions << transaction
        end

        transaction.is_opening = true
      end
    end
  end
end
