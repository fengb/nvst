FactoryGirl.define do
  factory :expense do
    date     { Date.current - rand(100) }
    amount   { rand(10.0..1000.0).to_d.round(2) }
    category { Expense.category.values.sample }
    vendor   { FFaker::Company.name }
    memo     ''
  end
end
