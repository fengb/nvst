FactoryGirl.define do
  factory :expense do
    date     { Date.today - rand(100) }
    amount   { rand(10.0..1000.0).to_d.round(2) }
    category { Expense.category.values.sample }
    vendor   { Faker::Company.name }
    memo     ''
  end
end
