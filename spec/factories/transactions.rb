FactoryGirl.define do
  factory :transaction do
    date       { Date.today - rand(100..300) }
    tax_date   { date }
    shares     { rand(100.0..1000.0).to_d.round(2) }
    price      { rand(10.0..100.0).to_d.round(2) }

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
